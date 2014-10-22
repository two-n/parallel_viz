require.config
  paths:
    'jquery': '../vendor/jquery/dist/jquery.min'
    'd3': '../vendor/d3/d3'
    'threejs': '../vendor/threejs/build/three'
  shim:
    'd3': exports: 'd3'
    "/vendor/FBOUtils.js": {
      deps: ["threejs"]
    }
    "/vendor/OrbitControls.js": {
      deps: ["threejs"]
    }

requirejs( ['d3', 'threejs', '/vendor/FBOUtils.js' , '/vendor/OrbitControls.js'], (d3, threejs) ->

  texSize = 128
  simulationShader = null
  fboParticles = null
  material = null
  controls = null
  renderer = null
  scene = null
  camera = null

  init = () ->
    renderer = new THREE.WebGLRenderer()
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 10000)
    camera.position.z = 0.8
    scene = new THREE.Scene()

    d3.json("/data/bt-state1.json", (err, state1) ->
      d3.json("/data/bt-state2.json", (err, state2) ->

        #data processing variables
        state = []
        window.state = state
        state.push state1
        state.push state2
        textures = []
        colorTextures = []
        sizeTextures = []

        #make position, color and size textures
        state.map (d,i) ->
          dataLength = state[i].nodes.length

          extent = {
            x: d3.extent( state[i].nodes , (d) -> d.x)
            y: d3.extent( state[i].nodes , (d) -> d.y)
          }

          scale = {
            x: d3.scale.linear().domain(extent.x).range([-0.5,0.5])
            y: d3.scale.linear().domain(extent.y).range([-0.5,0.5])
          }

          data = (new Float32Array(texSize*texSize*3))
          colorData = (new Float32Array(texSize*texSize*3))
          sizeData = (new Float32Array(texSize*texSize*3))
          [0...data.length].forEach (i) -> data[i] = 0
          [0...colorData.length].forEach (i) -> colorData[i] = 0
          [0...sizeData.length].forEach (i) -> sizeData[i] = 0
          state[i].nodes.map (d,j) ->
            data[j*3] = scale.x(d.x)
            data[j*3+1] = scale.y(d.y)

            colorIn = d.color.substr(1)
            colorData[j*3] = parseInt(colorIn.substr(0,2),16)/255
            colorData[j*3+1] = parseInt(colorIn.substr(2,2),16)/255
            colorData[j*3+2] = parseInt(colorIn.substr(4,2),16)/255

            sizeData[j*3] = parseFloat(d.r)*2.9
            sizeData[j*3+1] = 0
            sizeData[j*3+2] = 0

          texture = new THREE.DataTexture(data, texSize, texSize, THREE.RGBFormat, THREE.FloatType)
          texture.minFilter = THREE.NearestFilter
          texture.magFilter = THREE.NearestFilter
          texture.needsUpdate = true
          textures.push texture

          colorTexture = new THREE.DataTexture(colorData, texSize, texSize, THREE.RGBFormat, THREE.FloatType)
          colorTexture.minFilter = THREE.NearestFilter
          colorTexture.magFilter = THREE.NearestFilter
          colorTexture.needsUpdate = true
          colorTextures.push colorTexture

          sizeTexture = new THREE.DataTexture(sizeData, texSize, texSize, THREE.RGBFormat, THREE.FloatType)
          sizeTexture.minFilter = THREE.NearestFilter
          sizeTexture.magFilter = THREE.NearestFilter
          sizeTexture.needsUpdate = true
          sizeTextures.push sizeTexture


        #fbo system construction
        inPos = new THREE.WebGLRenderTarget(texSize,texSize, {
          wrapS:THREE.RepeatWrapping
          wrapT:THREE.RepeatWrapping
          minFilter: THREE.NearestFilter
          magFilter: THREE.NearestFilter
          format: THREE.RGBFormat
          type:THREE.FloatType
          stencilBuffer: false
        })
        outPos = inPos.clone()

        simulationShader = new THREE.ShaderMaterial({
            uniforms: {
                start: { type: "t", value: textures[0] }
                end: { type: "t", value: textures[1] }
                timer: { type: "f", value: 0}
            }
            vertexShader: document.getElementById('fboVert').innerHTML,
            fragmentShader:  document.getElementById('fboFrag').innerHTML
        })

        fboParticles = new THREE.FBOUtils( texSize, renderer, simulationShader );
        fboParticles.renderToTexture(inPos, outPos);

        fboParticles.in = inPos;
        fboParticles.out = outPos;

        #geometry construction
        geometry = new THREE.Geometry();

        [0...texSize*texSize].forEach (i) ->
          vertex = new THREE.Vector3()
          vertex.x = ( i % texSize ) / texSize
          vertex.y = Math.floor( i / texSize ) / texSize
          geometry.vertices.push( vertex )

        #construct render material
        sprite = THREE.ImageUtils.loadTexture( "/textures/ring_transp_256.png" )
        material = new THREE.ShaderMaterial {
            uniforms: {
                "map": { type: "t", value: inPos }
                "width": { type: "f", value: texSize }
                "height": { type: "f", value: texSize }
                "pointSize": { type: "f", value: 2 }
                "startColor": { type: "t", value: colorTextures[0] }
                "endColor": { type: "t", value: colorTextures[1] }
                "startSize": { type: "t", value: sizeTextures[0] }
                "endSize": { type: "t", value: sizeTextures[1] }
                "timer": { type: "f", value: 0}
                "sprite": { type: "t", value: sprite }
            }
            vertexShader: document.getElementById('fboRenderVert').innerHTML
            fragmentShader: document.getElementById('fboRenderFrag').innerHTML
            depthTest: true
            transparent: true
            blending: THREE.NormalBlending
        }

        #final setup
        mesh = new THREE.PointCloud( geometry, material )
        scene.add( mesh )

        controls = new THREE.OrbitControls( camera, renderer.domElement )
        renderer.setSize(window.innerWidth, window.innerHeight)

        document.body.appendChild(renderer.domElement)
      )
    )

  transTime = 1
  forward = false

  animate = (t) ->
    requestAnimationFrame(animate);

    if forward
      useTime = transTime
    else
      useTime = 1 - transTime

    simulationShader.uniforms.timer.value = useTime
    material.uniforms.timer.value = useTime

    fboParticles.simulate(fboParticles.out)
    material.uniforms.map.value = fboParticles.out

    controls.update()
    renderer.render( scene, camera )

  init()

  document.addEventListener("contextmenu", (e) ->
    forward = not forward
    transTime = 0
    d3.transition().duration(5000).tween("timer", () ->
      return (t) ->
        transTime = t
    )
  )

  animate(new Date().getTime());

)