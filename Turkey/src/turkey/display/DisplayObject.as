package turkey.display
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import turkey.TurkeyRenderer;
	import turkey.core.Turkey;
	import turkey.errors.AbstractMethodError;
	import turkey.events.EventDispatcher;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	import turkey.utils.MatrixUtil;
	import turkey.utils.VertexData;
	
	[Event(name="turkeyClick", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyRightClick", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyMouseMove", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyMouseOver", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyMouseOut", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyMouseDown", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyMouseUp", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyRightMouseDown", type="turkey.events.TurkeyMouseEvent")]
	[Event(name="turkeyRightMouseUp", type="turkey.events.TurkeyMouseEvent")]
	/** Dispatched when an object is added to a parent. */
	[Event(name="added", type="turkey.events.Event")]
	/** Dispatched when an object is connected to the stage (directly or indirectly). */
	[Event(name="addedToStage", type="turkey.events.Event")]
	/** Dispatched when an object is removed from its parent. */
	[Event(name="removed", type="turkey.events.Event")]
	/** Dispatched when an object is removed from the stage and won't be rendered any longer. */ 
	[Event(name="removedFromStage", type="turkey.events.Event")]
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
		protected var _colorMatrix:Matrix3D;
		protected var _alpha:Number=1;
		protected var _visible:Boolean = true;
		protected var _blendMode:String = "normal";
		protected var _parent:DisplayObjectContainer;
		protected var _filters:Array;
		protected var _transformationMatrix:Matrix;
		private var _mouseOut:Boolean = true;
		protected var _selfBounds:Rectangle = new Rectangle();
		
		protected var _vertexData:VertexData;
		private static var sAncestors:Vector.<DisplayObject> = new <DisplayObject>[];
		private var sHelperMatrix:Matrix = new Matrix();
		private var sHelperRectangle:Rectangle = new Rectangle();
		protected static var _helpPoint:Point=new Point();
		private var _matrixChanged:Boolean;
		
		public function DisplayObject()
		{
			_transformationMatrix = new Matrix();
			_colorMatrix = new Matrix3D();
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
			return getBounds(_parent, sHelperRectangle).width;
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
			return getBounds(_parent, sHelperRectangle).height;
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
		/**
		 * 
		 * @return 注册点X
		 * 
		 */		
		public function get pivotX():Number { return _pivotX; }
		public function set pivotX(value:Number):void 
		{
			if(_pivotX == value)return;
			_pivotX = value;
			_matrixChanged = true;
		}
		/**
		 * 
		 * @return 注册点Y 
		 * 
		 */		
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
			if(parent)
			{
				if(_mouseEnabled)parent.addToMouseHitList(this);
				else parent.removeFromMouseHitList(this);
			}
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
				_stageMousePoint.setTo(Turkey.stage.stage2D.mouseX,Turkey.stage.stage2D.mouseY);
				if(_mouseOut)
				{
					dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_OUT,this,mouseX,mouseY,_stageMousePoint.x,_stageMousePoint.y));
				}else
				{
					dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_OVER,this,mouseX,mouseY,_stageMousePoint.x,_stageMousePoint.y));
				}
			}
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
			{
				throw new ArgumentError("An object cannot be added as a child to itself or one " +
					"of its children (or children's children, etc.)");
			}else
			{
				_parent = value; 
				getBounds(this,_selfBounds);
			}
		}
		
		internal function removeFromParent():void
		{
			if(_parent) 
			{
				_parent.removeChild(this);
				_parent = null;
			}
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
			_stageMousePoint.setTo(Turkey.stage.stage2D.mouseX,Turkey.stage.stage2D.mouseY);
			globalToLocal(_stageMousePoint);_localMousePoint.setTo(_helpPoint.x,_helpPoint.y);
			return _localMousePoint.x;
		}
		
		public function get mouseY():Number
		{
			_stageMousePoint.setTo(Turkey.stage.stage2D.mouseX,Turkey.stage.stage2D.mouseY);
			globalToLocal(_stageMousePoint);_localMousePoint.setTo(_helpPoint.x,_helpPoint.y);
			return _localMousePoint.y;
		}
		/**
		 *	
		 * @param localPoint 本地坐标点
		 * @param forMouse	是否是鼠标碰撞，如果是鼠标碰撞，会受到mouseEnable与mouseChildren的影响
		 * @return localPoint碰撞到的显示对象
		 * 
		 */		
		public function hitTest(localPoint:Point,forMouse:Boolean = false):DisplayObject
		{
			return _selfBounds.contains(localPoint.x,localPoint.y)?this:null;
		}
		
		public function get texture():Texture
		{
			return null;
		}
		
		/** The root object the display object is connected to (i.e. an instance of the class 
		 *  that was passed to the Starling constructor), or null if the object is not connected
		 *  to the Turkey.stage. */
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
		
		public function localToGlobal(localPoint:Point):Point
		{
			getTransformationMatrix(base, sHelperMatrix);
			return MatrixUtil.transformCoords(sHelperMatrix, localPoint.x, localPoint.y, _helpPoint);
		}
		
		public function globalToLocal(globalPoint:Point):Point
		{
			getTransformationMatrix(base, sHelperMatrix);
			sHelperMatrix.invert();
			return MatrixUtil.transformCoords(sHelperMatrix, globalPoint.x, globalPoint.y, _helpPoint);
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
		/**
		 * 
		 * @return 本地位置信息的二维矩阵
		 * 
		 */		
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
				getBounds(this,_selfBounds);
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
				trace("[Turkey] Cannot calculate individual transformation matrix properties.",
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
			return _visible && _alpha != 0.0 && _scaleX != 0.0 && _scaleY != 0.0;
		}
		/**
		 *	加入到渲染队列当中，如果有滤镜，则添加进渲染队列，并且渲染(因为如果有子对象，可以一次画完以后，再一次运用滤镜，而不必对每个子对象都分别运用滤镜，可以提高效率)
		 * @param parentMatrix 父对象的二维空间矩阵
		 * @param parentColorMatrix 父对象的颜色矩阵
		 * @param parentAlpha 父对象的渲染透明度
		 * @param parentFilter 父对象是否带滤镜，如果父对象带滤镜，滤镜渲染时，等候父对象的滤镜渲染时再渲染到缓冲区
		 * 
		 */		
		public function addToRenderList(parentMatrix:Matrix,parentColorMatrix:Matrix3D,parentAlpha:Number,parentFilter:Boolean):void
		{
//			if(!hasVisibleArea)return;
			var hasFilter:Boolean = filters && filters.length>0;
			if(hasFilter)
			{
				TurkeyRenderer.preFilter();
			}
			MatrixUtil.prependMatrix(parentMatrix,transformationMatrix);
			parentColorMatrix.append(_colorMatrix);
			TurkeyRenderer.addChildForRender(this,parentMatrix,parentColorMatrix,parentAlpha*alpha);
			if(hasFilter)
			{
				TurkeyRenderer.render();
				var len:int = filters.length;
				for(var i:int=0;i<len;i++)
				{
					filters[i].render((i==len-1&&!parentFilter));
				}
				TurkeyRenderer.endFilter();
			}
		}
		
		private var _dragHelpPoint:Point;
		private var _dragHelpPoint2:Point;
		private var _dragHelpBoolean:Boolean;
		public function dragStart():void
		{
			_dragHelpBoolean = Turkey.stage.mouseMoveEnable;
			Turkey.stage.mouseMoveEnable = true;
			_dragHelpPoint = new Point(Turkey.stage.mouseX,Turkey.stage.mouseY);
			_dragHelpPoint2 = new Point(x,y);
			Turkey.stage.addEventListener(TurkeyMouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onMouseMove(event:TurkeyMouseEvent):void
		{
			var p:Point = new Point(event.stageX,event.stageY);
			x = _dragHelpPoint2.x + p.x - _dragHelpPoint.x;
			y = _dragHelpPoint2.y + p.y - _dragHelpPoint.y;
		}
		
		public function dragStop():void
		{
			Turkey.stage.mouseMoveEnable = _dragHelpBoolean;
			Turkey.stage.removeEventListener(TurkeyMouseEvent.MOUSE_MOVE,onMouseMove);
		}

		public function get colorMatrix():Matrix3D
		{
			return _colorMatrix;
		}

		public function set colorMatrix(value:Matrix3D):void
		{
			_colorMatrix = value;
		}
		
		public function dispose():void
		{
			if(parent)
				parent.removeChild(this);
			_vertexData = null;
			filters = null;
		}

	}
}