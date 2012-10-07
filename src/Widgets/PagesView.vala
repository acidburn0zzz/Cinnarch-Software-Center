//
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
using Lsc.Pages;

namespace Lsc.Widgets {
    public class PagesView : Notebook {
        public HomePage home_page;
        public AppsView apps_view;
        public AppsInfo apps_info;
        
        public void set_page (PageType page) {
            if (page == get_current_page()) {
                switch_page(get_nth_page((int)page), page);
            } else {
                set_current_page(page);
            }
        }
        
        public PagesView () {
            show_border = false;
            show_tabs = false;
            
            home_page = new HomePage();
            /*ScrolledWindow home_page_scroll = new ScrolledWindow(null, null);
            home_page_scroll.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
            home_page_scroll.add_with_viewport(home_page);
            ((Viewport)home_page_scroll.get_child()).set_shadow_type (ShadowType.NONE);*/
            append_page(home_page, null);
            
            apps_view = new AppsView();
            append_page(apps_view, null);
            
            apps_info = new AppsInfo();
            /*ScrolledWindow apps_info_scroll = new ScrolledWindow(null, null);
            apps_info_scroll.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
            apps_info_scroll.add_with_viewport(apps_info);
            ((Viewport)apps_info_scroll.get_child()).set_shadow_type (ShadowType.NONE);*/
            append_page(apps_info, null);
        }
    }
}
