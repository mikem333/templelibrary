/*
 *	 
 *	Temple Library for ActionScript 3.0
 *	Copyright © 2012 MediaMonks B.V.
 *	All rights reserved.
 *	
 *	http://code.google.com/p/templelibrary/
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
 *	
 *	Note: This license does not apply to 3rd party classes inside the Temple
 *	repository with their own license!
 *	
 */

package temple.ui.pagination
{
	import flash.events.Event;

	/**
	 * Event for pagination navigation.
	 * 
	 * @see http://en.wikipedia.org/wiki/Pagination
	 * 
	 * @author Thijs Broerse
	 */
	public class PaginatorEvent extends Event
	{
		/**
		 * Go to the next page
		 */
		public static const NEXT_PAGE:String = "nextPage";

		/**
		 * Go to the previous page
		 */
		public static const PREVIOUS_PAGE:String = "previousPage";

		/**
		 * Go to the first page.
		 */
		public static const FIRST_PAGE:String = "firstPage";
		
		/**
		 * Go to the last page.
		 */
		public static const LAST_PAGE:String = "lastPage";

		/**
		 * Go to the page with a specific number, note: pages are zero based.
		 */
		public static const GOTO_PAGE:String = "gotoPage";
		
		private var _page:uint;
		
		public function PaginatorEvent(type:String, page:uint = 0, bubbles:Boolean = false)
		{
			super(type, bubbles);
			
			this._page = page;
		}

		/**
		 * Index of the page
		 */
		public function get page():uint
		{
			return this._page;
		}
		
		override public function clone():Event
		{
			return new PaginatorEvent(this.type, this._page);
		}
	}
}