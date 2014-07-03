require.config
  paths:
    'jquery': '../vendor/jquery/dist/jquery.min'
    'd3': '../vendor/d3/d3'
    'threejs': '../vendor/threejs/build/three'

requirejs( ['d3', 'threejs'], (d3, threejs) ->

  w = 600
  h = 200

  margin = {
    left: 10
    right: 10
    top: 10
    bottom: 10
  }

  numNodes = 15
  data = [0..numNodes-1].map () ->
    {
      x: Math.random()
      y: Math.random()
    }

  xScale = d3.scale.linear().range([w,0]).domain([0,1])
  yScale = d3.scale.linear().range([0,h]).domain([0,1])

  labelAnchors = []
  labelAnchorLinks = []

  for d,i in data
    node = {
      label : "node " + i
    }
    labelAnchors.push {
      node: node
    }
    labelAnchors.push {
      node: node
    }

  for d,i in data
    labelAnchorLinks.push {
      source : i * 2,
      target : i * 2 + 1,
      weight : 1
    }

  force2 = d3.layout.force()
    .nodes(labelAnchors)
    .links(labelAnchorLinks)
    .gravity(0)
    .linkDistance(0)
    .linkStrength(8)
    .charge(-100)
    .size([w, h])

  force2.start()

  svg = d3.select("body").append("svg")
    .attr("width", w + margin.left + margin.right)
    .attr("height", h + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  node = svg.selectAll(".dot")
      .data(data)
    .enter().append("svg:circle")
      .attr("r", 3.5)
      .attr("cx", (d) -> xScale(d.x))
      .attr("cy", (d) -> yScale(d.y))
      .style("fill", (d) -> "red")

  anchorNode = svg.selectAll("g.anchorNode")
    .data(force2.nodes()).enter()
    .append("svg:g")
    .attr("class", "anchorNode");
  anchorNode.
    append("svg:circle")
    .attr("r", 0)
    .style("fill", "#FFF")
  anchorNode
    .append("svg:text")
    .text( (d, i) ->
      i % 2 == 0 ? "" : d.node.label
    )
    .style("fill", "#555")
    .style("font-family", "Arial")
    .style("font-size", 12);

  anchorLink = svg.selectAll("line.anchorLink").data(labelAnchorLinks)

  # console.log anchorNode

  anchorNode.each (d, i) ->
    console.log d.node
    if(i % 2 == 0)
      d.x = d.node.x
      d.y = d.node.y
    else
      b = this.childNodes[1].getBBox()

      diffX = d.x - d.node.x
      diffY = d.y - d.node.y

      dist = Math.sqrt(diffX * diffX + diffY * diffY)

      shiftX = b.width * (diffX - dist) / (dist * 2)
      shiftX = Math.max(-b.width, Math.min(0, shiftX))
      shiftY = 5
      this.childNodes[1].setAttribute("transform", "translate(" + shiftX + "," + shiftY + ")")
)