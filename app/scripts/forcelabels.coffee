require.config
  paths:
    'jquery': '../vendor/jquery/dist/jquery.min'
    'd3': '../vendor/d3/d3'
    'threejs': '../vendor/threejs/build/three'

requirejs( ['d3', 'threejs'], (d3, threejs) ->
  w = 800
  h = 600

  margin = 100

  # seed = 0

  #
  random = (s) ->
        s = Math.sin(s) * 100000;
        s - Math.floor(s)

  svg = d3.select("body").append("svg:svg").attr("width", w).attr("height", h)

  labelAnchors = []
  labelAnchorLinks = []

  xScale = d3.scale.linear().range([w-margin,margin]).domain([0,1])
  yScale = d3.scale.linear().range([margin,h-margin]).domain([0,1])

  numNodes = 80
  data = [0..numNodes-1].map (i) ->
    if seed?
      {
        x: random(i+seed+numNodes)
        y: random(i+seed)
      }
    else
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

  updateLabels = () ->
    anchorNode.each( (d, i) ->
      if(i % 2 == 0)
        d.x = d.node.x
        d.y = d.node.y
      else
        #align label on its vector
        b = this.childNodes[0].getBBox()
        diffX = d.x - d.node.x
        diffY = d.y - d.node.y
        dist = Math.sqrt(diffX * diffX + diffY * diffY)
        shiftX = b.width * (diffX - dist) / (dist * 2)
        shiftX = Math.max(-b.width, Math.min(0, shiftX))
        shiftY = 0
        this.childNodes[0].setAttribute("transform", "translate(" + shiftX + "," + shiftY + ")")
    )

    anchorNode.call(updateNode)
    anchorLink.call(updateLink)

  force = d3.layout.force()
    .nodes(labelAnchors)
    .links(labelAnchorLinks)
    .gravity(0)
    .linkDistance(1)
    .linkStrength(8)
    .charge(-200)
    .size([w, h])
    .on("tick",updateLabels)
    .start()

  node = svg.selectAll("g.node").data(nodes).enter().append("svg:g").attr("class", "node")
  node.append("svg:circle").attr("r", 5).style("fill", "#00").style("stroke", "#FFF").style("stroke-width", 3)

  anchorLink = svg.selectAll("line.anchorLink").data(labelAnchorLinks).enter().append("svg:line").attr("class", "anchorLink").style("stroke", "#999")

  anchorNode = svg.selectAll("g.anchorNode").data(force.nodes()).enter().append("svg:g").attr("class", "anchorNode")
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

  node.call(updateNode)
)
