#!/usr/bin/perl


use strict;

use Getopt::ArgParse ;
use Text::Lorem;
use Text::Wrap;
use LWP::Simple;
use JSON::XS;
use DDP;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);


my $logger = get_logger();

# $logger -> debug ("Program invoked with args: @ARGV");

my @random_images = ();
my $images_initialized = 0;


my $ap = Getopt::ArgParse->new_parser(
        prog        => "$0" ,
        description => 'program generates fake QML model for app modelling.',
        epilog      => 'Please correct the invocation of command.',
);


my $modelhelp = qq{Model in fieldname:type[:range-min:range-max] format eg:
id:number,name:string,age:number,city:string (simple)
id:number,name:string:,age:number:20:65,city:string:2:6 (full)

possible types:

'string' : a short text consiting of 3 to 5 words.
  'text' : a chunk of text consiting of 1 to 4 sentences.
'number' : a random number between 0 100
'float'  : a floating point value between 0 100
'serial' : an autoincremting number with each list element.
'epoch'  : an epoch value (unix timestamp) between min to max days from now . (use negative for timestamps of past)
'image'  : this will put a random photo url from flickr https://api.flickr.com/services/feeds/photos_public.gne?tags=nature

range specs:
each type can be optionally followed by min:max that allows
to specify the range of length of text or values of numbers.
};

$ap->add_arg('--model'   , '-m', type=>'Array' , split=> ',' ,  required => 1 , help => $modelhelp );
$ap->add_arg('--name'    , '-n', type=>'Scalar' ,required => 1 , help => 'name of model' );
$ap->add_arg('--count'    , '-c', type=>'Scalar' ,default => 2 , help => 'howmany elements in model' );
$ap->add_arg('--sep'    , '-s', type=>'Scalar' ,default => 'space' , choices=>[ 'space', 'tab'] ,  help => 'indent preference' );
$ap->add_arg('--sepcount' , '-sc', type=>'Scalar' ,default => 4 , help => 'separator count' );



my $ns = $ap->parse_args();
my @model  = $ns->model  ;
my $name   = $ns->name   ;
my $count  = $ns->count  ;
my $sep    = $ns->sep eq 'space' ? " " : "\t"  ;
my $sepcount  = $ns->sepcount ;


my $lorem = Text::Lorem->new();
$Text::Wrap::columns = 40;

my $model = qq!
import QtQuick 2.0;

$name {!;

my $seq=1;

for(1..$count) {
		$model .= &ListElement();
}

$model .= qq!\n}\n!;

print $model;


sub ListElement {

		my ($h) = @_;

		my $spacing = $sep x $sepcount;
		my $le = qq!\n$spacing ListElement {!;
		my $rand;

		my $fakevalue ;
		foreach my $f (@model) {
				my ($name,$type,$min,$max) = split /\s*:\s*/ , $f;

				$fakevalue ="";

				if ($type eq 'string') {
					$rand = randNumber(  $min || 3 , $max || 5);
					$fakevalue = "'" . $lorem -> words($rand) . "'"  ;
				} elsif ($type eq 'text') {

					$rand = randNumber(  $min || 1 , $max || 4);
					my $sentances =  $lorem -> sentences($rand) ;

					my @lines = split "\n" , wrap('', '', $sentances );

					my $lines =  join "\n$spacing$spacing$spacing$spacing+ " , map { "'$_'";  }   @lines;


					$fakevalue = $lines  ;
				} elsif ($type eq 'number') {
					$rand = randNumber(  $min || 0 , $max || 100);
					$fakevalue = int $rand ; 

				} elsif ($type eq 'serial') {

					$fakevalue = $seq++; 

				} elsif ($type eq 'float') {
					$rand = randNumber(  $min || 0 , $max || 100);
					$fakevalue = $rand;
				} elsif ($type eq 'epoch') {
					my $now = time ;
					my $randdays = randNumber($min || -30 , $max || 0);
					$fakevalue = int( $now + $randdays * 86400);
				} elsif ($type eq 'imageurl') {
						if (! $images_initialized) {
								my $tag = $min ;
								&initRandomFlickerPhotos($tag || 'nature' ) ;
						}
						my $url =  $random_images[ rand @random_images ];
						$fakevalue = "'" . $url . "'"  ;
				}

				else {

					warn "sorry invalid type specified : $type\n";
					$ap->print_usage;
					exit 1;

				}

				$le .= "\n$spacing$spacing$spacing$name: $fakevalue";
		}

		$le .= qq!\n$spacing}!;

		return $le;

}

sub randNumber {
	my ($min , $max) = @_;
	return $min + rand ($max-$min);
}



sub initRandomFlickerPhotos {

	my ($tag) = @_;

	my $url = "https://api.flickr.com/services/feeds/photos_public.gne?tags=$tag&format=json";

 	my $content = get($url);
  die "Couldn't get flicker data , please check connectivity and retry!\n" unless defined $content;
	$content =~ m#jsonFlickrFeed\((.*)\)#s;
	my $json = $1;
  die "Couldn't get json data!\n" unless $json;

	my $data  = decode_json $json ;

	my @items = @{$data->{items}} ;

	@random_images = map { $_->{media}->{m} } @items;

	$images_initialized = 1;

}
