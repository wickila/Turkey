package turkey.display
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getQualifiedClassName;
	
	import turkey.enumrate.BlendMode;
	import turkey.errors.AbstractClassError;
	import turkey.errors.AbstractMethodError;
	import turkey.events.EventDispatcher;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	import turkey.utils.MatrixUtil;
	import turkey.utils.VertexData;
	
	public class DisplayObject extends EventDispatcher
	{
		protected var _x:Number=0;
		protected var _y:Number=0;
		protected var _z:Number=0;
		
		protected var _rotation:Number=0;
		protected var _width:Number=0;
		protected var _height:Number=0;
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;
		protected var _pivotX:Number = 0;
		protected var _pivotY:Number = 0;
		private var _localMousePoint:Point = new Point();
		private var _stageMousePoint:Point = new Point();
		
		protected var _mouseEnabled:Boolean=true;
		protected var _buttonMode:Boolean = false;
		protected var _alpha:Number=1;
		protected var _visible:Boolean = true;
		protected var _blendMode:String = BlendMode.NORMAL;
		protected var _parent:DisplayObjectContainer;
		protected var _filters:Array;
		protected var _transformationMatrix:Matrix;
		protected var _pixelHit:Boolean=false;
		private var _mouseOut:Boolean = true;
		
		protected var _vertexData:VertexData;
		private static var sAncestors:Vector.<DisplayObject> = new <DisplayObject>[];
		private var sHelperMatrix:Matrix = new Matrix();
		private var sHelperRectangle:Rectangle = new Rectangle();
		private var _matrixChanged:Boolean;
		
		public function DisplayObject()
		{
			if (Capabilities.isDebugger && 
				getQualifiedClassName(this) == "starling.display::DisplayObject")
			{
				throw new AbstractClassError();
			}
			_transformationMatrix = new Matrix();
		}

		public function get pixelHit():Boolean
		{
			return _pixelHit;
		}

		public function set pixelHit(value:Boolean):void
		{
			_pixelHit = value;
		}

		public function get buttonMode():Boolean
		{
			return _buttonMode;
		}

		public function set buttonMode(value:Boolean):void
		{
			if(_buttonMode == value)return;
			_buttonMode = value;
			Mouse.cursor = (_mouseEnabled && _buttonMode && !_mouseOut) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}

		internal function get mouseOut():Boolean
		{
			return _mouseOut;
		}

		internal function set mouseOut(value:Boolean):void
		{
			if(_mouseOut == value)return;
			_mouseOut = value;
			if(_mouseEnabled)
			{
				if(_mouseOut)
				{
					dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_OUT,this,mouseX,mouseY,_stageMousePoint.x,_stageMousePoint.y));
				}else
				{
					dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_OVER,this,mouseX,mouseY,_stageMousePoint.x,_stageMousePoint.y));
				}
			}
			Mouse.cursor = (_mouseEnabled && _buttonMode && !_mouseOut) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			if(_x == value) return;
			_x = value;
			_matrixChanged = true;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			if(_y == value)return;
			_y = value;
			_matrixChanged = true;
		}

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation(value:Number):void
		{
			if(_rotation == value)return;
			_rotation = value;
			_matrixChanged = true;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			scaleX = 1.0;
			var actualWidth:Number = width;
			if (actualWidth != 0.0) 
			{
				scaleX = value / actualWidth;
				_width = value;
			}
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			scaleY = 1.0;
			var actualHeight:Number = height;
			if (actualHeight != 0.0) 
			{
				scaleY = value / actualHeight;
				_height = value;
			}
		}
		
		public function get scaleX():Number
		{
			return _scaleX;
		}

		public function set scaleX(value:Number):void
		{
			if(_scaleX == value)return;
			_scaleX = value;
			_matrixChanged = true;
		}
		
		public function get scaleY():Number
		{
			return _scaleY;
		}

		public function set scaleY(value:Number):void
		{
			if(_scaleY == value)return;
			_scaleY = value;
			_matrixChanged = true;
		}
		
		public function get pivotX():Number { return _pivotX; }
		public function set pivotX(value:Number):void 
		{
			if(_pivotX == value)return;
			_pivotX = value;
			_matrixChanged = true;
		}
		
		public function get pivotY():Number { return _pivotY; }
		public function set pivotY(value:Number):void 
		{
			if(_pivotY == value)return;
			_pivotY = value;
			_matrixChanged = true
		}

		public function get mouseEnabled():Boolean
		{
			return _mouseEnabled;
		}

		public function set mouseEnabled(value:Boolean):void
		{
			if(_mouseEnabled == value)return;
			_mouseEnabled = value;
			Mouse.cursor = (_mouseEnabled && _buttonMode && !_mouseOut) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			_alpha = value;
		}

		public function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(value:Boolean):void
		{
			_visible = value;
		}

		public function get blendMode():String
		{
			return _blendMode;
		}

		public function set blendMode(value:String):void
		{
			_blendMode = value;
		}
		
		public function get vertexData():VertexData
		{
			return _vertexData;
		}
		
		public function set vertexData(value:VertexData):void
		{
			_vertexData = value;
		}
		
		internal function setParent(value:DisplayObjectContainer):void 
		{
			var ancestor:DisplayObject = value;
//			while (ancestor != this && ancestor != null)
//				ancestor = ancestor.parent;
//			
			if (ancestor == this)
				throw new ArgumentError("An object cannot be added as a child to itself or one " +
					"of its children (or children's children, etc.)");
			else
				_parent = value; 
		}
		
		internal function removeFromParent():void
		{
			if(_parent) _parent.removeChild(this);
		}

		public function get parent():DisplayObjectContainer
		{
			return _parent;
		}

		public function get filters():Array
		{
			return _filters;
		}

		public function set filters(value:Array):void
		{
			_filters = value;
		}
		
		public function get mouseX():Number
		{
			return _localMousePoint.x;
		}
		
		public function get mouseY():Number
		{
			return _localMousePoint.y;
		}
		
		public function hitTest(localPoint:Point,forMouse:Boolean = false):DisplayObject
		{
			return getBounds(this,sHelperRectangle).contains(localPoint.x,localPoint.y)?this:null;
		}
		
		public function get texture():Texture
		{
			return null;
		}
		
		/** The root object the display object is connected to (i.e. an instance of the class 
		 *  that was passed to the Starling constructor), or null if the object is not connected
		 *  to the stage. */
		public function get root():DisplayObject
		{
			var currentObject:DisplayObject = this;
			while (currentObject.parent)
			{
				if (currentObject.parent is Stage) return currentObject;
				else currentObject = currentObject.parent;
			}
			
			return null;
		}
		
		public function get stage():Stage
		{
			return base as Stage;
		}
		
		public function localToGlobal(localPoint:Point, resultPoint:Point=null):Point
		{
			getTransformationMatrix(base, sHelperMatrix);
			return MatrixUtil.transformCoords(sHelperMatrix, localPoint.x, localPoint.y, resultPoint);
		}
		
		public function globalToLocal(globalPoint:Point, resultPoint:Point=null):Point
		{
			getTransformationMatrix(base, sHelperMatrix);
			sHelperMatrix.invert();
			return MatrixUtil.transformCoords(sHelperMatrix, globalPoint.x, globalPoint.y, resultPoint);
		}
		
		public function getTransformationMatrix(targetSpace:DisplayObject, 
												resultMatrix:Matrix=null):Matrix
		{
			var commonParent:DisplayObject;
			var currentObject:DisplayObject;
			
			if (resultMatrix) resultMatrix.identity();
			else resultMatrix = new Matrix();
			
			if (targetSpace == this)
			{
				return resultMatrix;
			}
			else if (targetSpace == parent || (targetSpace == null && parent == null))
			{
				resultMatrix.copyFrom(transformationMatrix);
				return resultMatrix;
			}
			else if (targetSpace == null || targetSpace == base)
			{
				// targetCoordinateSpace 'null' represents the target space of the base object.
				// -> move up from this to base
				
				currentObject = this;
				while (currentObject != targetSpace)
				{
					resultMatrix.concat(currentObject.transformationMatrix);
					currentObject = currentObject.parent;
				}
				
				return resultMatrix;
			}
			else if (targetSpace.parent == this) // optimization
			{
				targetSpace.getTransformationMatrix(this, resultMatrix);
				resultMatrix.invert();
				
				return resultMatrix;
			}
			
			// 1. find a common parent of this and the target space
			
			commonParent = null;
			currentObject = this;
			
			while (currentObject)
			{
				sAncestors.push(currentObject);
				currentObject = currentObject.parent;
			}
			
			currentObject = targetSpace;
			while (currentObject && sAncestors.indexOf(currentObject) == -1)
				currentObject = currentObject.parent;
			
			sAncestors.length = 0;
			
			if (currentObject) commonParent = currentObject;
			else throw new ArgumentError("Object not connected to target");
			
			// 2. move up from this to common parent
			
			currentObject = this;
			while (currentObject != commonParent)
			{
				resultMatrix.concat(currentObject.transformationMatrix);
				currentObject = currentObject.parent;
			}
			
			if (commonParent == targetSpace)
				return resultMatrix;
			
			// 3. now move up from target until we reach the common parent
			
			sHelperMatrix.identity();
			currentObject = targetSpace;
			while (currentObject != commonParent)
			{
				sHelperMatrix.concat(currentObject.transformationMatrix);
				currentObject = currentObject.parent;
			}
			
			// 4. now combine the two matrices
			
			sHelperMatrix.invert();
			resultMatrix.concat(sHelperMatrix);
			
			return resultMatrix;
		}     
		
		public function get transformationMatrix():Matrix
		{
			if(_matrixChanged)
			{
				_transformationMatrix.identity();
				if (scaleX != 1.0 || scaleY != 1.0) _transformationMatrix.scale(scaleX, scaleY);
				if (rotation != 0.0)                 _transformationMatrix.rotate(rotation);
				if (x != 0.0 || y != 0.0)           _transformationMatrix.translate(x, y);
				
				if (_pivotX != 0.0 || _pivotY != 0.0)
				{
					_transformationMatrix.tx = x - _transformationMatrix.a * _pivotX
						- _transformationMatrix.c * _pivotY;
					_transformationMatrix.ty = y - _transformationMatrix.b * _pivotX 
						- _transformationMatrix.d * _pivotY;
				}
				_matrixChanged = false;
			}
			return _transformationMatrix; 
		}
		
		public function set transformationMatrix(matrix:Matrix):void
		{
			_transformationMatrix.copyFrom(matrix);
			
			var aa:Number = matrix.a * matrix.a;
			var bb:Number = matrix.b * matrix.b;
			var cc:Number = matrix.c * matrix.c;
			var dd:Number = matrix.d * matrix.d;
			
			if (isEquivalent(bb/(aa+bb), cc/(dd+cc)))
			{
				var sinRot:Number = Math.sqrt(bb/(aa+bb));
				
				if ((matrix.a >= 0 && matrix.b < 0) || (matrix.a < 0 && matrix.b >= 0)) 
					sinRot *= -1;
				
				rotation = Math.asin(sinRot);
				scaleX = rotation ?  matrix.b / sinRot : matrix.a;
				scaleY = rotation ? -matrix.c / sinRot : matrix.d;
				x = matrix.tx;
				y = matrix.ty;
				_pivotX = _pivotY = 0;
			}else
			{
				trace("[Starling] Cannot calculate individual transformation matrix properties.",
					"This warning is issued only once.");
			}
		}
		
		private final function isEquivalent(a:Number, b:Number, epsilon:Number=0.0001):Boolean
		{
			return (a - epsilon < b) && (a + epsilon > b);
		}
		
		public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			throw new AbstractMethodError("Method needs to be implemented in subclass");
			return null;
		}
		
		internal function get base():DisplayObject
		{
			var currentObject:DisplayObject = this;
			while (currentObject.parent) currentObject = currentObject.parent;
			return currentObject;
		}
		
		public function get hasVisibleArea():Boolean
		{
			return _alpha != 0.0 && _visible && _scaleX != 0.0 && _scaleY != 0.0;
		}
		
		public function hitMouse(stageX:Number,stageY:Number):void
		{
			_stageMousePoint.setTo(stageX,stageY);
			globalToLocal(_stageMousePoint,_localMousePoint);
			if(mouseEnabled && hitTest(_localMousePoint,true))
			{
				mouseOut = false;
			}else
			{
				mouseOut = true;
			}
		}
	}
}