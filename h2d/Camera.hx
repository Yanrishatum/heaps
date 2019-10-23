package h2d;

class Camera {

	/**
		X position of the camera top-left corner in world space.
	**/
	public var x(default, set) : Float;
	/**
		Y position of the camera top-left corner in world space.
	**/
	public var y(default, set) : Float;

	/**
		Horizontal scale factor of the camera. Scaling applied relative to anchored position.
	**/
	public var scaleX(default, set) : Float;
	/**
		Vertical scale factor of the camera. Scalid applied relative to anchored position.
	**/
	public var scaleY(default, set) : Float;

	/**
		Rotation of the camera in radians. Camera is rotated around anchored position.
	**/
	public var rotation(default, set) : Float;

	/** X position of the camera anchor point based on `anchorX`. **/
	public var viewX(get, set) : Float;
	/** Y position of the camera anchor point based on `anchorY`. **/
	public var viewY(get, set) : Float;

	// TODO: viewport (clip/size manipulation)

	/** Horizontal anchor position inside viewport boundaries used for anchoring and resize compensation. ( default : 0.5 ) **/
	public var anchorX(default, set) : Float;
	/** Vertical anchor position inside viewport boundaries used for anchoring and resize compensation. ( default : 0.5 ) **/
	public var anchorY(default, set) : Float;

	public var visible : Bool;

	var ratioChanged : Bool;
	var sceneWidth : Int;
	var sceneHeight : Int;
	var anchorWidth : Float;
	var anchorHeight : Float;
	var scene : Scene;
	
	var posChanged : Bool;

	var matA : Float;
	var matB : Float;
	var matC : Float;
	var matD : Float;
	var absX : Float;
	var absY : Float;

	public function new( anchorX : Float = 0, anchorY : Float = 0 ) {
		this.x = 0; this.y = 0;
		this.scaleX = 1; this.scaleY = 1;
		this.rotation = 0;
		this.anchorX = anchorX;
		this.anchorY = anchorY;
		this.anchorWidth = 0; this.anchorHeight = 0;
		this.sceneWidth = 0; this.sceneHeight = 0;
		this.visible = true;
		ratioChanged = true;
	}

	/**
		Override this method to set visibility only to specific layers
	**/
	public dynamic function layerVisible( layer : Int ) : Bool {
		return true;
	}

	public function enter( ctx : RenderContext ) {
		// Improvement: Handle camera-in-camera rendering
		ctx.setCamera(this);
		@:privateAccess trace(ctx.viewX,ctx.viewY);
	}

	public function exit( ctx : RenderContext ) {
		// Improvement: Restore previous camera
		ctx.resetCamera();
	}

	// Setters

	inline function set_x( v ) {
		posChanged = true;
		return this.x = v;
	}

	inline function set_y( v ) {
		posChanged = true;
		return this.y = v;
	}

	inline function set_scaleX( v ) {
		posChanged = true;
		return this.scaleX = v;
	}

	inline function set_scaleY( v ) {
		posChanged = true;
		return this.scaleY = v;
	}

	inline function set_rotation( v ) {
		posChanged = true;
		return this.rotation = v;
	}

	// TODO
	inline function get_viewX() { return this.x; }
	inline function get_viewY() { return this.y; }

	inline function set_viewX( v : Float ) {
		this.x = v;
		return v;
	}
	inline function set_viewY( v : Float ) {
		this.y = v;
		return v;
	}

	inline function set_anchorX( v ) {
		anchorX = hxd.Math.clamp(v, 0, 1);
		anchorWidth = sceneWidth * anchorX;
		return anchorX;
	}

	inline function set_anchorY( v ) {
		anchorY = hxd.Math.clamp(v, 0, 1);
		anchorHeight = sceneHeight * anchorY;
		return anchorY;
	}

	public function sync( ctx : RenderContext )
	{
		if ( posChanged ) {
			var scene = ctx.scene;
			if ( rotation == 0 ) {
				matA = scaleX;
				matB = 0;
				matC = 0;
				matD = scaleY;
			} else {
				var cr = Math.cos(rotation);
				var sr = Math.sin(rotation);
				matA = scaleX * cr;
				matB = scaleX * sr;
				matC = scaleY * -sr;
				matD = scaleY * cr;
			}
			var ox = scene.width * -anchorX;
			var oy = scene.height * -anchorY;
			absX = (ox - x) * matA + (oy - y) * matC;
			absY = (ox - x) * matB + (oy - y) * matD;
			// TODO: Viewport
			// TODO: Optimize?
			posChanged = false;
		}
		// TODO: Somehow mark posChanged when scene gets resized.
	}

}