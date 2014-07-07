require.config
  paths:
    'jquery': '../vendor/jquery/dist/jquery.min'
    'd3': '../vendor/d3/d3'
    'threejs': '../vendor/threejs/build/three'

requirejs( ['d3', 'threejs'], (d3, threejs) ->
  w = 960
  h = 500

  labelDistance = 0

  vis = d3.select("body").append("svg:svg").attr("width", w).attr("height", h)

  labelAnchors = []
  labelAnchorLinks = []

  xScale = d3.scale.linear().range([w,0]).domain([0,1])
  yScale = d3.scale.linear().range([0,h]).domain([0,1])

  numNodes = 45
  data = [0..numNodes-1].map () ->
    {
      x: Math.random()
      y: Math.random()
    }

  nodes = []
  for d in data
    node = {
      cx: xScale(d.x)
      cy: yScale(d.y)
      x: xScale(d.x)
      y: yScale(d.y)
      label : "it's label time!"
    }
    nodes.push node
    labelAnchors.push {
      node : node
    }
    labelAnchors.push {
      node : node
    }

  for d,i in nodes
    labelAnchorLinks.push {
      source : i * 2
      target : i * 2 + 1
      weight : 1
    }

  force = d3.layout.force()
    .nodes(labelAnchors)
    .links(labelAnchorLinks)
    .gravity(0)
    .linkDistance(0)
    .linkStrength(8)
    .charge(-100)
    .size([w, h])

  force.start()

  node = vis.selectAll("g.node").data(nodes).enter().append("svg:g").attr("class", "node")
  node.append("svg:circle").attr("r", 5).style("fill", "#555").style("stroke", "#FFF").style("stroke-width", 3)

  anchorLink = vis.selectAll("line.anchorLink").data(labelAnchorLinks).enter().append("svg:line").attr("class", "anchorLink").style("stroke", "#999")

  anchorNode = vis.selectAll("g.anchorNode").data(force.nodes()).enter().append("svg:g").attr("class", "anchorNode")
  anchorNode.append("svg:circle").attr("r", 0).style("fill", "#FFF")
  anchorNode.append("svg:text").text((d, i) -> if i % 2 is 0 then return "" else return d.node.label
  ).style("fill", "#555").style("font-family", "Arial").style("font-size", 12)

  updateLink = () ->
    this.attr("x1", (d) ->
      d.source.x
    ).attr("y1", (d) ->
      d.source.y
    ).attr("x2", (d) ->
      d.target.x
    ).attr("y2", (d) ->
      d.target.y
    )

  updateNode = () ->
    this.attr("transform", (d) ->
      return "translate(" + d.x + "," + d.y + ")"
    )

  updateLabels = () ->
    force.start()

    node.call(updateNode)

    anchorNode.each( (d, i) ->
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

    anchorNode.call(updateNode)
    anchorLink.call(updateLink)

  setInterval((updateLabels),10)

)
