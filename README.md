# fakemodel
Generates placeholder QML models based on specifications


# usage

```
usage: ./genmodel.pl --name|-n --model|-m [--help|-h] [--sepcount|-sc]
[--sep|-s] [--count|-c]

program generates fake QML model for app modelling.

required named arguments:
  --name, -n NAME        name of model
  --model, -m MODEL      Model in fieldname:type[:range-min:range-max] format eg:
                           id:number,name:string,age:number,city:string (simple)
                           id:number,name:string:,age:number:20:65,city:string:2:6
                           (full)
                           
                           possible types:
                           
                           'string' : a short text consiting of 3 to 5 words.
                             'text' : a chunk of text consiting of 1 to 4 sentences.
                           'number' : a random number between 0 100
                           'float'  : a floating point value between 0 100
                           'serial' : an autoincremting number with each list element.
                           'epoch'  : an epoch value (unix timestamp) between min to
                           max days from now . (use negative for timestamps of past)
                           
                           range specs:
                           each type can be optionally followed by min:max that allows
                           to specify the range of length of text or values of
                           numbers.

optional named arguments:
  --help, -h                  ? show this help message and exit
  --sepcount, -sc SEPCOUNT    ? separator count
                                  Default: 4
  --sep, -s SEP               ? indent preference
                                  Choices: [space, tab], case sensitive
                                  Default: space
  --count, -c COUNT           ? howmany elements in model
                                  Default: 2

Please correct the invocation of command.

```

# example output

`./genmodel.pl --model "student_id:serial,name:string,age:number:18:30,resume:text,generated:epoch:-30:0" --name Students --count 4`

```

import QtQuick 2.0;

Students {
     ListElement {
            student_id: 1
            name: 'porro explicabo perferendis odio'
            age: 24
            resume: 'Cumque ipsam voluptatibus eaque.'
            generated: 1512067712
    }
     ListElement {
            student_id: 2
            name: 'rerum cum expedita'
            age: 20
            resume: 'Ut non deserunt fuga velit excepturi.'
            generated: 1512284673
    }
     ListElement {
            student_id: 3
            name: 'provident voluptatum tempore recusandae'
            age: 28
            resume: 'Inventore perspiciatis est quisquam.'
                + 'Beatae necessitatibus vero mollitia a'
                + 'sint nostrum omnis. Aut et tempora'
                + 'ducimus delectus porro et soluta.'
            generated: 1511454873
    }
     ListElement {
            student_id: 4
            name: 'est porro exercitationem non'
            age: 18
            resume: 'Accusantium vitae deserunt magni'
                + 'soluta.'
            generated: 1512164838
    }
}

```
