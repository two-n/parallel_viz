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

  nodes = []
  labelAnchors = []
  labelAnchorLinks = []
  links = []

  for i in [0..29]
    node = {
      label : "node " + i
      fixed : true
    }
    nodes.push node
    labelAnchors.push {
      node : node
    }
    labelAnchors.push {
      node : node
    }

  for d,i in nodes
    # for j in [0..i]
      # if Math.random() > 0.95
        # links.push {
        #     source : i
        #     target : j
        #     weight : Math.random()
        #   }
    labelAnchorLinks.push {
      source : i * 2
      target : i * 2 + 1
      weight : 1
    }

  # console.log links

  force = d3.layout.force()
    .size([w, h])
    .nodes(nodes)
    .links(links)
    .gravity(1)
    .linkDistance(50)
    .charge(-3000)
    .linkStrength((x) -> x.weight * 10)

  force.start()

  force2 = d3.layout.force()
    .nodes(labelAnchors)
    .links(labelAnchorLinks)
    .gravity(0)
    .linkDistance(0)
    .linkStrength(8)
    .charge(-100)
    .size([w, h])

  force2.start()

  link = vis.selectAll("line.link").data(links).enter().append("svg:line").attr("class", "link").style("stroke", "#CCC")

  node = vis.selectAll("g.node").data(force.nodes()).enter().append("svg:g").attr("class", "node")
  node.append("svg:circle").attr("r", 5).style("fill", "#555").style("stroke", "#FFF").style("stroke-width", 3)
  node.call(force.drag)


  anchorLink = vis.selectAll("line.anchorLink").data(labelAnchorLinks).enter().append("svg:line").attr("class", "anchorLink").style("stroke", "#999")

  anchorNode = vis.selectAll("g.anchorNode").data(force2.nodes()).enter().append("svg:g").attr("class", "anchorNode")
  anchorNode.append("svg:circle").attr("r", 0).style("fill", "#FFF")
  anchorNode.append("svg:text").text((d, i) ->
    if i % 2 is 0
      ""
    else
      d.node.label
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
    force2.start()

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

    link.call(updateLink)
    anchorLink.call(updateLink)

  force.on("tick", updateLabels)

)
