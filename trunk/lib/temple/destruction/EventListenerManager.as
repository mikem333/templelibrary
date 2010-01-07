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

package temple.destruction 
{
	import temple.debug.errors.TempleArgumentError;
	import temple.debug.errors.throwError;
	import temple.core.CoreObject;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * The EventListenerManager store information about event listeners on an object. Since all listeners are stored they can easely be removed, by type, listener or all.
	 * The EventListenerManager only stores information about strong (non weak) listeners. Since storing a reference to listener will make the listener strong.
	 */
	public class EventListenerManager extends CoreObject implements IEventDispatcher, IDestructableEventDispatcher 

		/**
		 * Returns a list of all listeners of the dispatcher (registered by the EventListenerManager)
		 * @param dispatcher The dispatcher you want info about
		 */
		public static function getDispatcherInfo(dispatcher:IDestructableEventDispatcher):Array
		{
			var list:Array = new Array();
			
			var listenerManager:EventListenerManager = dispatcher.eventListenerManager;
			
			if (listenerManager && listenerManager._events.length)
			{
				for each (var eventData:EventData in listenerManager._events)
				{
					list.push(eventData.type);
				}
			}
			return list;
		}
		/**
		 * @param eventDispatcher the EventDispatcher of this EventListenerManager
			this._eventDispatcher = eventDispatcher;
			super();
			
			if(eventDispatcher == null) throwError(new TempleArgumentError(this, "dispatcher can not be null"));
			if(eventDispatcher.eventListenerManager) throwError(new TempleError(this, "dispatcher already has an EventListenerManager"));
		}
		
		/**
		 * Returns a reference to the EventDispatcher
		 */
		public function get eventDispatcher():IEventDispatcher
		{
			return this._eventDispatcher;
		}
		 * 	
			// Don't store weak reference info, since storing the listener will make it strong
			if(useWeakReference) return;
			
			{
			}
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean 
			return this._eventDispatcher.dispatchEvent(event);
			return this._eventDispatcher.hasEventListener(type);
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean 
			return this._eventDispatcher.willTrigger(type);
			{
				{
				}
			}
		 * @inheritDoc
		 */
		public function removeAllStrongEventListenersForType(type:String):void 
					
					eventData.destruct();
		 * @inheritDoc
		 */
		public function removeAllStrongEventListenersForListener(listener:Function):void 
					
					eventData.destruct();
		 * @inheritDoc
		 */
		public function removeAllEventListeners():void 
			if (this._events)
			{
					
					eventData.destruct();
			}
		
		/**
		 * @inheritDoc
		 */
		public function get eventListenerManager():EventListenerManager
		{
			return null;
		}
		 * @inheritDoc
		 */
		override public function destruct():void 
			this.removeAllEventListeners();
			for each (var eventData:EventData in this._events) eventData.destruct();
			
			this._eventDispatcher = null;
			this._events = null;
			
			super.destruct();
		}

		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return super.toString() + ": " + this._eventDispatcher;
	}

import temple.debug.getClassName;

class EventData
		this.listener = listener;
		
		super();

	/**
	 * Destructs the object
	 */
	public function destruct():void
	{
		this.type = null;
		this.listener = null;
	}
	
	public function toString():String
	{
		return getClassName(this) + ": " + this.type;
	}