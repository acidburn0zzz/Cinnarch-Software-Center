//  Copyright © 2012 Stephen Smally
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.
//      

using Gtk;
using Lsc.Widgets;

namespace Lsc.Pages {
    public class HomePage : Box {
        public CategoriesView categories_view;
        
        public HomePage () {
            orientation = Orientation.VERTICAL;
            spacing = 5;
            //border_width = 5;
            
            categories_view = new CategoriesView();
            //categories_view.halign = Align.CENTER;
            categories_view.hexpand = true;
            
            pack_start(categories_view, true, true, 0);
        }
    }
}
