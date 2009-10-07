/*
 *	 
 *	Temple Library for ActionScript 3.0
 *	Copyright © 2009 MediaMonks B.V.
 *	All rights reserved.
 *	
 *	THIS LIBRARY IS IN PRIVATE BETA, THEREFORE THE SOURCES MAY NOT BE
 *	REDISTRIBUTED IN ANY WAY.
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	
 *	- Redistributions of source code must retain the above copyright notice,
 *	this list of conditions and the following disclaimer.
 *	
 *	- Redistributions in binary form must reproduce the above copyright notice,
 *	this list of conditions and the following disclaimer in the documentation
 *	and/or other materials provided with the distribution.
 *	
 *	- Neither the name of the Temple Library nor the names of its contributors
 *	may be used to endorse or promote products derived from this software
 *	without specific prior written permission.
 *	
 *	
 *	Temple Library is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *	
 *	Temple Library is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *	
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with Temple Library.  If not, see <http://www.gnu.org/licenses/>.
 *	
 */

package temple.core 
{
	import temple.destruction.IDestructableOnError;
	import temple.data.loader.IPreloader;
	import temple.data.loader.PreloadableBehavior;
	import temple.debug.Registry;
	import temple.debug.log.Log;
	import temple.destruction.DestructEvent;
	import temple.destruction.EventListenerManager;
	import temple.destruction.IDestructableEventDispatcher;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.getQualifiedClassName;

	/**
	 * Dispatched just before the object is destructed
	 * @eventType temple.destruction.DestructEvent.DESTRUCT
	 */
	[Event(name = "DestructEvent.destruct", type = "temple.destruction.DestructEvent")]
	
	/**
	 * Base class for all URLLoaders in the Temple. The CoreURLLoader handles some core features of the Temple:
	 * <ul>
	 * 	<li>Registration to the Registry class</li>
	 * 	<li>Event dispatch optimalisation</li>
	 * 	<li>Easy remove of all EventListeners</li>
	 * 	<li>Wrapper for Log class for easy logging</li>
	 * 	<li>Completely destructable</li>
	 * 	<li>Can be tracked in Memory (of this feature is enabled)</li>
	 * 	<li>Logs IOErrorEvents and SecurityErrorEvents</li>
	 * </ul>
	 * 
	 * You should always use and/or extend the CoreURLLoader instead of URLLoader if you want to make use of the Temple features.
	 * 
	 * @author Thijs Broerse
	 */
	public class CoreURLStream extends URLStream implements IDestructableEventDispatcher, ICoreLoader, IDestructableOnError
	{
		private static const _DEFAULT_HANDLER : int = -50;
		
		private namespace temple;
		
		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;
		protected var _destructOnError:Boolean;
		protected var _logErrors:Boolean;
		protected var _preloadableBehavior:PreloadableBehavior;
		
		private var _listenerManager:EventListenerManager;
		private var _isDestructed:Boolean;
		private var _registryId:uint;
		private var _url:String;

		/**
		 * Creates a DestructableURLLoader
		 * @param request optional URLRequest to load
		 * @param destructOnError if set to true (default) this object wil automaticly be destructed on an Error (IOError or SecurityError)
		 * @param logErrors if set to true an error message wil be logged on an Error (IOError or SecurityError)
		 */
		public function CoreURLStream(destructOnError:Boolean = true, logErrors:Boolean = true)
		{
			super();
			
			this._listenerManager = new EventListenerManager(this);
			
			this._destructOnError = destructOnError;
			this._logErrors = logErrors;
			
			// Register object for destruction testing
			this._registryId = Registry.add(this);
			
			// Add default listeners to Error events and preloader support
			this.addEventListener(Event.OPEN, temple::handleLoadStart);
			this.addEventListener(ProgressEvent.PROGRESS, temple::handleLoadProgress);
			this.addEventListener(Event.COMPLETE, temple::handleLoadComplete);
			this.addEventListener(IOErrorEvent.IO_ERROR, temple::handleIOError, false, CoreURLStream._DEFAULT_HANDLER);
			this.addEventListener(IOErrorEvent.DISK_ERROR, temple::handleIOError, false, CoreURLStream._DEFAULT_HANDLER);
			this.addEventListener(IOErrorEvent.NETWORK_ERROR, temple::handleIOError, false, CoreURLStream._DEFAULT_HANDLER);
			this.addEventListener(IOErrorEvent.VERIFY_ERROR, temple::handleIOError, false, CoreURLStream._DEFAULT_HANDLER);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, temple::handleSecurityError, false, CoreURLStream._DEFAULT_HANDLER);
			
			// preloader support
			this._preloadableBehavior = new PreloadableBehavior(this);
		}


		/**
		 * @inheritDoc
		 */ 
		override public function load(request:URLRequest):void
		{
			super.load(request);
			this._url = request.url;
			this._isLoading = true;
			this._isLoaded = false;
		}

		/**
		 * @inheritDoc
		 */ 
		override public function close():void
		{
			super.close();
			this._isLoading = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function isLoading():Boolean
		{
			return this._isLoading;
		}
		
		/**
		 * @inheritDoc
		 */
		public function isLoaded():Boolean
		{
			return this._isLoaded;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get url():String
		{
			return this._url;
		}
			
		/**
		 * @inheritDoc
		 */
		public function get logErrors():Boolean
		{
			return this._logErrors;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set logErrors(value:Boolean):void
		{
			this._logErrors = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get destructOnError():Boolean
		{
			return this._destructOnError;
		}

		/**
		 * @inheritDoc
		 */
		public function set destructOnError(value:Boolean):void
		{
			this._destructOnError = value;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Check implemented if object hasEventListener, must speed up the application
		 * http://www.gskinner.com/blog/archives/2008/12/making_dispatch.html
		 */
		override public function dispatchEvent(event:Event):Boolean 
		{
			if (this.hasEventListener(event.type) || event.bubbles) 
			{
				return super.dispatchEvent(event);
		  	}
		 	return true;
		}

		/**
		 * @inheritDoc
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			this._listenerManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * @inheritDoc
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			super.removeEventListener(type, listener, useCapture);
			if (this._listenerManager) this._listenerManager.removeEventListener(type, listener, useCapture);
		}

		/**
		 * @inheritDoc
		 */
		public function removeAllEventsForType(type:String):void 
		{
			this._listenerManager.removeAllEventsForType(type);
		}

		/**
		 * @inheritDoc
		 */
		public function removeAllEventsForListener(listener:Function):void 
		{
			this._listenerManager.removeAllEventsForListener(listener);
		}

		/**
		 * @inheritDoc
		 */
		public function removeAllEventListeners():void 
		{
			this._listenerManager.removeAllEventListeners();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get listenerManager():EventListenerManager
		{
			return this._listenerManager;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get preloader():IPreloader
		{
			return this._preloadableBehavior.preloader;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set preloader(value:IPreloader):void
		{
			this._preloadableBehavior.preloader = value;
		}
		
		temple function handleLoadStart(event:Event):void
		{
			this._preloadableBehavior.onLoadStart(event);
		}

		temple function handleLoadProgress(event:ProgressEvent):void
		{
			this._preloadableBehavior.onLoadProgress(event);
		}
		
		temple function handleLoadComplete(event:Event):void
		{
			this._preloadableBehavior.onLoadComplete(event);
			this._isLoading = false;
			this._isLoaded = false;
		}
		
		/**
		 * Default IOError handler
		 * If logErrors is set to true, a error log message is traced
		 */
		temple function handleIOError(event:IOErrorEvent):void
		{
			this._isLoading = false;
			this._preloadableBehavior.onLoadComplete(event);
			if (this._logErrors) this.logError(event.type + ': ' + event.text);
			if (this._destructOnError) this.destruct();
		}
		
		/**
		 * Default SecurityError handler
		 * If logErrors is set to true, a error log message is traced
		 */
		temple function handleSecurityError(event:SecurityErrorEvent):void
		{
			this._isLoading = false;
			this._preloadableBehavior.onLoadComplete(event);
			if (this._logErrors) this.logError(event.type + ': ' + event.text);
			if (this._destructOnError) this.destruct();
		}
		
		/**
		 * Log wrapper functions
		 */
		protected final function logDebug(data:*):void
		{
			Log.debug(data, this, this._registryId);
		}
		protected final function logError(data:*):void
		{
			Log.error(data, this, this._registryId);
		}
		protected final function logFatal(data:*):void
		{
			Log.fatal(data, this, this._registryId);
		}
		protected final function logInfo(data:*):void
		{
			Log.info(data, this, this._registryId);
		}
		protected final function logStatus(data:*):void
		{
			Log.status(data, this, this._registryId);
		}
		protected final function logWarn(data:*):void
		{
			Log.warn(data, this, this._registryId);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isDestructed():Boolean
		{
			return this._isDestructed;
		}

		/**
		 * @inheritDoc
		 */
		public function destruct():void 
		{
			if (this._isDestructed) return;
			
			this._preloadableBehavior.destruct();
			
			this.dispatchEvent(new DestructEvent(DestructEvent.DESTRUCT));
			
			if (this._isLoading) this.close();
			
			if (this._listenerManager)
			{
				this.removeAllEventListeners();
				this._listenerManager.destruct();
				this._listenerManager = null;
			}
			
			this._isDestructed = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return getQualifiedClassName(this);
		}
	}
}
