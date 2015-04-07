# hypothetical way to render http://blog.turing.io/images/article_images/error_to_communicate/proof_of_concept-e2d4c91d.png
# Seems like it would take a lot of work, though, and I'm not totally sure how to map it to HTML/CSS

# =====  KEY  =====
  defn:      - a tree definition named "defn"
  defn:<     - a tree definition named "defn" with one child, a node named "defn"
  node       - a node named "node"
               if a leaf, then its children may be provided as text
               or zero or more of any kind of node
  *node      - zero or more nodes named "node"
  $ref       - node named "ref" whose children come from a structure definition named "ref"
  ?node      - zero or one nodes named "node"
  .class     - a boolean attribute on the containing node (ie a css class)
  node.class - node has the boolean attribute "attr"

# =====  TEMPLATE  =====
main:
  error_type
    class
    explanation
  heuristic
  backtrace
    *$codeview

wrong_number_of_arguments:
  $codeview
  $codeview

codeview:
  path
    ?.emphasize
    dir
    file
    ?line_num
  code
    *codeline
      ?.emphasize
      ?linenum
      line
      ?annotation

message:<
details:<
standout:<

# =====  STYLE  =====

error_type {
  display:       block;
  border-top:    2px solid white;
  border-bottom: 2px solid white;
}
error_type class {
  color: #fff;
  border-right: 1px solid white;
}
error_type explanation message  { color: #F00 }
error_type explanation details  { color: #A00 }
error_type explanation standout { color: #FFF }

path            { display: block; }
path.emphasize  { text-decoration: underline; }
path dir        { color: #088; }
path file       { color: #08C; }
path line_num   { color: #04C; }

# should be grayed out if not emphasize
code            { display: block; }
code codeline   { display: block; }
code linenum    { linenum: #04C; }
code line       { }
code annotation {
  background-color: #F00;
  color:            #FFF;
  text-transform:   uppercase;
}


# =====  DATA  =====
bt0 = backtrace[0]
bt2 = backtrace[1]
main: {
  error_type: {
    class: 'ArgumentError',
    explanation: [
      {message: 'wrong number of arguments'},
      {details: [
        '(sent ',
        {standout: 3},
        ' expected ',
        {standout: 2},
        ')',
      ]}
    ]
  },
  heuristic: [
    {codeview: {
      path: {
        dir:     File.dirname(bt0.path),
        file:    File.basename(bt0.path),
        linenum: bt0.linenum,
      },
      code: File.read(bt0.path)[bt0.linenum, 5].map.with_index(bt0.linenum) { |line, linenum|
        { emphasize:  true,
          linenum:    linenum,
          line:       line,
          annotation: ('Expected 2' if linenum == bt0.linenum),
        }
      },
    }},
    {codeview: {
      path: {
        dir:     File.dirname(bt1.path),
        file:    File.basename(bt1.path),
        linenum: bt1.linenum,
      },
      code: File.read(bt1.path)[bt1.linenum, 5].map.with_index(bt1.linenum) { |line, linenum|
        { emphasize:  true,
          linenum:    linenum,
          line:       line,
          annotation: ('Sent 3' if linenum == bt1.linenum)
        }
      },
    }},
  ],
  backtrace: backtrace.map { |location|
    { path: {
        emphasize: true,
        dir:       File.dirname(location.path),
        file:      File.basename(location.path),
        linenum:   location.linenum,
      },
      code: {
        linenum:   location.linenum,
        line:      File.read(location.path).lines[location.linenum-1],
      }
    }
  }
}
