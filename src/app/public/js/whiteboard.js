
var graphJSON = "";

var graph = null;
var paper = null;
var toolsView = null;

$(document).ready(function() {
  // var board = new fabric.Canvas('board');
  // board.isDrawingMode = vue.isFreehand;
  // board.freeDrawingBrush.color = '#000000';
  // board.freeDrawingBrush.width = 5;

  // board.on('mouse:down', function(options) {
  //   if (options.target) {
  //     console.log('an object was clicked! ', options.target.type);
  //     vue.selected = options.target;
  //   }
  // });

  // board.on('mouse:over', function(element) {
  //   if(vue.selected) {
  //     vue.selected.set('active', true);
  //     vue.selected.set('hasRotatingPoint', false);
  //     vue.selected.set('hasBorders', false);
  //     vue.selected.set('transparentCorners', false);
  //     vue.selected.setControlsVisibility({ tl: false, tr: false, br: false, bl: false });
  //   }
  // });


  // vue.board = board;


  graph = new joint.dia.Graph;
  paper = new joint.dia.Paper({ 
　  el: $('#paper'), 
　　width: 800, 
    height: 800, 
    gridSize: 10, 
    model: graph,
    gridSize: 10,
    drawGrid: true,
    // background: {
    //     color: 'rgba(0, 255, 0, 0.3)'
    // }
  });

  var verticesTool = new joint.linkTools.Vertices({
      redundancyRemoval: true,
      snapRadius: 10,
      vertexAdding: true,
  });
  var segmentsTool = new joint.linkTools.Segments();
  var sourceArrowheadTool = new joint.linkTools.SourceArrowhead();
  var targetArrowheadTool = new joint.linkTools.TargetArrowhead();
  var sourceAnchorTool = new joint.linkTools.SourceAnchor();
  var targetAnchorTool = new joint.linkTools.TargetAnchor();
  var boundaryTool = new joint.linkTools.Boundary();
  var removeButton = new joint.linkTools.Remove();

  toolsView = new joint.dia.ToolsView({
      tools: [
          verticesTool, segmentsTool,
          sourceArrowheadTool, targetArrowheadTool,
          sourceAnchorTool, targetAnchorTool,
          boundaryTool, removeButton
      ]
  });


  // paper.scale(0.7, 0.7);
  // paper.translate(300, 50);
  paper.scale(0.7, 0.7);
  paper.translate(0, 0);

  var info = new joint.shapes.standard.Rectangle();
  info.position(200, 130);
  info.resize(100, 40);
  info.addTo(graph);



  var rect = new joint.shapes.standard.Rectangle();
  rect.position(100, 30);
  rect.resize(100, 40);
  rect.attr({
      body: {
          fill: 'white'
      },
      label: {
          text: 'Hello',
          fill: 'Black'
      }
  });
  rect.addTo(graph);

  var rect2 = rect.clone();
  rect2.translate(300, 0);
  rect2.attr('label/text', 'World!');
  rect2.addTo(graph);

  var link = new joint.shapes.standard.Link();
  link.labels([{
      attrs: {
          text: {
              text: 'Hello, World'
          }
      }
  }]);
  link.source(rect);
  link.target(rect2);
  link.addTo(graph);


  var linkView = link.findView(paper);
  linkView.addTools(toolsView);
  linkView.hideTools();

  function reset() {
    var elements = paper.model.getElements();
    for (var i = 0, ii = elements.length; i < ii; i++) {
        var currentElement = elements[i];
        currentElement.attr('body/stroke', 'black');
        currentElement.attr('label/fill', 'black');
        currentElement.findView(paper).hideTools();
    }

    var links = paper.model.getLinks();
    for (var j = 0, jj = links.length; j < jj; j++) {
        var currentLink = links[j];
        currentLink.attr('line/stroke', 'black');
        currentLink.label(0, {
            attrs: {
                body: {
                    stroke: 'black'
                },
                label: {
                    fill: 'black'
                }
            }
        });
        currentLink.findView(paper).hideTools();
    }
  }

  paper.on({
    'element:pointerdown': function(elementView, evt) {
        evt.data = elementView.model.position();
    },

    'element:pointerup': function(elementView, evt, x, y) {
      var coordinates = new g.Point(x, y);
      var elementAbove = elementView.model;
      var elementBelow = this.model.findModelsFromPoint(coordinates).find(function(el) {
        return (el.id !== elementAbove.id);
      });

      // If the two elements are connected already, don't
      // connect them again (this is application-specific though).
      if (elementBelow && graph.getNeighbors(elementBelow).indexOf(elementAbove) === -1) {

        // Move the element to the position before dragging.
        elementAbove.position(evt.data.x, evt.data.y);

        // Create a connection between elements.
        var link = new joint.shapes.standard.Link();

        link.source(elementAbove);
        link.target(elementBelow);
        link.addTo(graph);

        // Add remove button to the link.
        var tools = new joint.dia.ToolsView({
            tools: [new joint.linkTools.Remove()]
        });
        link.findView(this).addTools(tools);

        setDefaultLinkTool(link, paper);
      }
    }
  });

  // paper.on('link:mouseenter', function(linkView) {
  //     linkView.showTools();
  // });

  // paper.on('link:mouseleave', function(linkView) {
  //     linkView.hideTools();
  // });
  //
  
  function selectElement(elementView) {
    reset();
    var currentElement = elementView.model;
    currentElement.attr('body/stroke', 'orange')
    currentElement.attr('label/fill', 'orange')
    elementView.showTools();
    vue.selected = currentElement;
    vue.selectedType = "element";
  }

  function selectLink(linkView) {
    reset();
    var currentLink = linkView.model;
    currentLink.attr('line/stroke', 'orange')
    currentLink.label(0, {
      attrs: {
        body: {
          stroke: 'orange'
        },
        label: {
          fill: 'orange'
        }
      }
    });
    linkView.showTools();
    vue.selected = currentLink;
    vue.selectedType = "link";
  }

  function deselect() {
    reset();
    vue.selected = null;
    vue.selectedType = null;
  }

  paper.on('element:pointerclick', function(elementView) {
    selectElement(elementView);
  });

  paper.on('link:pointerclick', function(linkView) {
    selectLink(linkView);
  });

  paper.on('blank:pointerclick', function() {
    deselect();
  });

  // paper.on('blank:pointerdblclick', function() {
  //     resetAll(this);

  //     info.attr('body/visibility', 'hidden');
  //     info.attr('label/visibility', 'hidden');

  //     this.drawBackground({
  //         color: 'orange'
  //     })
  // });

  // paper.on('blank:pointerdblclick', function() {
  //     resetAll(this);

  //     info.attr('body/visibility', 'hidden');
  //     info.attr('label/visibility', 'hidden');

  //     this.drawBackground({
  //         color: 'orange'
  //     })
  // });

  // paper.on('element:pointerdblclick', function(elementView) {
  //     resetAll(this);

  //     var currentElement = elementView.model;
  //     currentElement.attr('body/stroke', 'orange')
  // });

  // paper.on('link:pointerdblclick', function(linkView) {
  //     resetAll(this);

  //     var currentLink = linkView.model;
  //     currentLink.attr('line/stroke', 'orange')
  //     currentLink.label(0, {
  //         attrs: {
  //             body: {
  //                 stroke: 'orange'
  //             }
  //         }
  //     })
  // });

  // paper.on('cell:pointerdblclick', function(cellView) {
  //     var isElement = cellView.model.isElement();
  //     var message = (isElement ? 'Element' : 'Link') + ' clicked';
  //     info.attr('label/text', message);

  //     info.attr('body/visibility', 'visible');
  //     info.attr('label/visibility', 'visible');
  // });

  // function resetAll(paper) {
  //     paper.drawBackground({
  //         color: 'white'
  //     })

  //     var elements = paper.model.getElements();
  //     for (var i = 0, ii = elements.length; i < ii; i++) {
  //         var currentElement = elements[i];
  //         currentElement.attr('body/stroke', 'black');
  //     }

  //     var links = paper.model.getLinks();
  //     for (var j = 0, jj = links.length; j < jj; j++) {
  //         var currentLink = links[j];
  //         currentLink.attr('line/stroke', 'black');
  //         currentLink.label(0, {
  //             attrs: {
  //                 body: {
  //                     stroke: 'black'
  //                 }
  //             }
  //         })
  //     }
  // }

  // graph.on('change:position', function(cell) {
  //     var center = cell.getBBox().center();
  //     var label = center.toString();
  //     cell.attr('label/text', label);
  // });


  // // 初期から出ているbox
  // var el1 = new joint.shapes.html.Element({
  //   position: { x: 80, y: 80 },
  //   size: { width: 170, height: 80 },
  //   divName: 'Atrae',
  //   isCompany: true
  // });

  // graph.addCells([el1]);

  // paper.on('cell:pointerup', function(cellView, evt, x, y) {
  //   var elementBelow = graph.get('cells').find(function(cell) {
  //     if (cell instanceof joint.dia.Link) return false;
  //     if (cell.id === cellView.model.id) return false;
  //     if (cell.getBBox().containsPoint(g.point(x, y))) return true;
  //     return false;
  //   });                                                                                                                                                        

  //   if (elementBelow && !_.contains(graph.getNeighbors(elementBelow), cellView.model)) {
  //     graph.addCell(new joint.shapes.org.Arrow({
  //       source: { id: cellView.model.id },
  //       target: { id: elementBelow.id }
  //     }));
  //     cellView.model.translate(-200, 0);
  //   }
  // });

  graphJSON = graph.toJSON();
  console.log(graphJSON);
});


function setDefaultLinkTool(link, paper) {
  var linkView = link.findView(paper);
  linkView.addTools(toolsView);
  linkView.hideTools();
}

// joint.shapes.html = {};
// joint.shapes.html.Element = joint.shapes.basic.Rect.extend({
//   defaults: joint.util.deepSupplement({
//     type: 'html.Element',
//     attrs: {
//       rect: { stroke: 'none', 'fill-opacity': 0 }
//     }
//   }, joint.shapes.basic.Rect.prototype.defaults)
// });
// 
// joint.shapes.html.ElementView = joint.dia.ElementView.extend({
//   template: [
//     '<div class="html-element">',
//     '<button class="delete">x</button>',
//     '<input type="text" value=""/>',
//     '<button class="js-divName"></button>',
//     '<button class="add">＋</button>',
//     '</div>'
//   ].join(''),
// 
//   initialize: function() {
//     _.bindAll(this, 'updateBox');
//     joint.dia.ElementView.prototype.initialize.apply(this, arguments);
// 
//     this.$box = $(_.template(this.template)());
//     this.$box.find('input').on('mousedown click', function(evt) { evt.stopPropagation(); });
// 
//     this.$box.find('input').on('change', _.bind(function(evt) {
//       this.model.set('divName', $(evt.target).val());
//     }, this));
// 
//     // delete element
//     this.$box.find('.delete').on('click', _.bind(this.model.remove, this.model));
//     this.$box.find('.add').on('click', _.bind(this.addBox, this.model));
//     this.model.on('change', this.updateBox, this);
//     this.model.on('remove', this.removeBox, this);
// 
//     if (this.model.get('isCompany') === true) {
//       this.$box.find('input').remove();
//       this.$box.find('.delete').remove();
//     }
//     this.updateBox();
//   },
//   render: function() {
//     joint.dia.ElementView.prototype.render.apply(this, arguments);
//     this.paper.$el.prepend(this.$box);
//     this.updateBox();
//     return this;
//   },
// 
//   updateBox: function() {
//     var bbox = this.model.getBBox();
//     this.$box.find('.js-divName').text(this.model.get('divName'));
//     this.$box.css({
//       width: bbox.width,
//       height: bbox.height,
//       left: bbox.x,
//       top: bbox.y,
//       transform: 'rotate(' + (this.model.get('angle') || 0) + 'deg)'
//     });
//   },
//   removeBox: function(evt) {
//     this.$box.remove();
//   },
//   addBox: function(evt) {
//     var el1 = new joint.shapes.html.Element({
//       position: { x: evt.clientX + 120, y: evt.clientY - 35 },
//       size: { width: 170, height: 80 },
//       divName: ''
//     });
// 
//     var line = new joint.shapes.org.Arrow({
//       source: { id: this.id },
//       target: { id: el1.id },
//       vertices: [{ x: 100, y: 120 }, { x: 150, y: 60 }]
//     });
//     graph.addCells([el1, line]);
//   }
// });



function addText(context, content, pLeft, pTop) {
  var text = new fabric.Text(content, {left: pLeft, top: pTop});
  context.add(text);
}

function addTextbox(context, content, pLeft, pTop) {
  var textbox = new fabric.Textbox(content, {
    left: pLeft, 
    top: pTop, 
    fontFamily: 'ＭＳ ゴシック',
    fontSize: 12
  });
  context.add(textbox);
}

function addRect(context, content, width, height, pLeft, pTop) {
  var rect = new joint.shapes.standard.Rectangle({
    position : { x : pLeft, y : pTop },
    size : { width : width, height : height },
    outPorts: ['out'],
    ports: {
        groups: {
            'in': {
                attrs: {
                    '.port-body': {
                        fill: '#16A085'
                    }
                }
            },
            'out': {
                attrs: {
                    '.port-body': {
                        fill: '#E74C3C'
                    }
                }
            }
        }
    },
  });
  // rect.position(pLeft, pTop);
  // rect.resize(width, height);
  rect.addTo(graph);
  rect.attr('label/text', content);
}

var vue = new Vue({
  el: '#vue-main',
  data: {
    board : null,
    isFreehand : false,
    editText : "",
    selected : null,
    selectedType : null
  },
  watch: {
    selected : 'onChangeSelected'
  },
  methods: {
    toggleFreehand : function() {
      this.isFreehand = !(this.isFreehand);
      this.board.isDrawingMode = this.isFreehand;
    },
    onClickBtnText : function() {
      addText(this.board, "abc", 100, 100);
    },
    onClickBtnTextbox : function() {
      addTextbox(this.board, "abc", 100, 100);
    },
    onClickBtnAddRect : function() {
      addRect(this.board, "abc", 100, 40, 200, 200);
    },
    onChangeSelected : function() {
      if((this.selected) && (this.selectedType === "element")) {
        this.editText = this.selected.attr('label/text');
      } 
      else if((this.selected) && (this.selectedType === "link")) {
        this.editText = this.selected.attr('text/text');
      } else {
        this.editText = "";
      }
    },
    onClickBtnSetText : function() {
      if((this.selected) && (this.selectedType === "element")) {
        this.selected.attr('label/text', this.editText);
      } 
      else if((this.selected) && (this.selectedType === "link")) {
        this.selected.attr('text/text', this.editText);
      }
    }
  },
  computed: {
    textBtnToggleFreehand : function() {
      return (this.isFreehand)? "Freehand" : "Shapes";
    }
  },
  updated: function () {

  }
});

