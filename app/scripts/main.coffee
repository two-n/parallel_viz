require.config
  paths:
    'jquery': '../vendor/jquery/dist/jquery.min'
    'd3': '../vendor/d3/d3'
    'threejs': '../vendor/threejs/build/three'

requirejs( ['d3', 'threejs'], (d3, threejs) ->

  vert = "void main() {
  gl_Position = projectionMatrix *
                modelViewMatrix *
                vec4(position,1.0);
  }"

  frag = "void main() {
  gl_FragColor = vec4(1.0,  // R
                      0.0,  // G
                      1.0,  // B
                      1.0); // A
  }"

  viewAngle = 75
  aspectRatio = window.innerWidth/window.innerHeight
  nearClip = 0.1
  farClip = 10000

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(viewAngle, aspectRatio, nearClip, farClip)

  renderer = new THREE.WebGLRenderer()
  renderer.setSize(window.innerWidth, window.innerHeight)
  document.body.appendChild(renderer.domElement)

  geometry = new THREE.BoxGeometry(1,1,1)

  material = new THREE.MeshLambertMaterial({color: 0xCC0000})
  material = new THREE.ShaderMaterial ->
    {
      vertexShader: vert,
      fragmentShader: frag
    }
  cube = new THREE.Mesh(geometry, material)
  scene.add(cube)

  pointLight = new THREE.PointLight(0xFFFFFF)

  pointLight.position.x = 10
  pointLight.position.y = 50
  pointLight.position.z = 130

  scene.add(pointLight)

  camera.position.z = 5

  render = () ->
    requestAnimationFrame(render)

    cube.rotation.x += 0.01
    cube.rotation.y += 0.01

    renderer.render(scene, camera)

  render()
)