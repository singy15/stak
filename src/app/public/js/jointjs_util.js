
function JointJSUtil() { }

JointJSUtil.prototype.createDefaultLinkToolsView = function() {
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

  return toolsView;
};

