package
{
	import feathers.controls.ScreenNavigator;
 
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
 
	public class SimpleTransitionManager
	{
		public function ScreenSlidingStackTransitionManager(navigator:ScreenNavigator)
		{
			//we'll need its dimensions later
			this.navigator = navigator;
 
			//our onTransition function is what the navigator calls
			//to start the transition
			this.navigator.transition = this.onTransition;
		}
 
		protected var navigator:ScreenNavigator;
		protected var tween:Tween;
		protected var savedOldScreen:DisplayObject;
		protected var savedCompleteCallback:Function;
 
		protected function onTransition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function):void
		{
			//if we're already transitioning, stop immediately
			if(this.tween)
			{
				this.savedOldScreen = null;
				this.savedCompleteCallback = null;
				Starling.juggler.remove(this.tween);
				this.tween = null;
			}
 
			//no need to animate if one of the screens is missing
			if(!oldScreen || !newScreen)
			{
				//make sure the screen that exists is at the right position
				if(newScreen)
				{
					newScreen.x = 0;
				}
				if(oldScreen)
				{
					oldScreen.x = 0;
				}
 
				//no animation, so let's finish immediately
				completeCallback();
				return;
			}
 
			//save this until the tween finishes
			this.savedCompleteCallback = completeCallback;
 
			//save this so that we can use it in the onUpdate callback
			this.savedOldScreen = oldScreen;
 
			//the old screen is on the left
			oldScreen.x = 0;
			//the new screen is on the right
			newScreen.x = this.navigator.width;
 
			//animate the new screen to x == 0
			this.tween = new Tween(newScreen, 0.25, Transitions.EASE_OUT);
			this.tween.animate("x", 0);
			this.tween.onUpdate = tween_onUpdate;
			this.tween.onComplete = tween_onComplete;
			Starling.juggler.add(this.tween);
		}
 
		protected function tween_onUpdate():void
		{
			//position the old screen relative to the new screen
			var newScreen:DisplayObject = DisplayObject(this.tween.target);
			this.savedOldScreen.x = newScreen.x - this.navigator.width;
		}
 
		protected function tween_onComplete():void
		{
			//we don't need to save these
			this.tween = null;
			this.savedOldScreen = null;
 
			var completeCallback:Function = this.savedCompleteCallback;
			this.savedCompleteCallback = null;
 
			//done!
			completeCallback();
		}
	}
}
