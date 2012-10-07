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
using Lsc.Utils;
using Lsc.Widgets;

namespace Lsc {
    // Elements which should be accessible to every void or class
    public AppStore.Category last_category;
    public AppStore.ModelApp last_app;
    
    public enum PageType {
        HOMEPAGE,
        APPSVIEW,
        APPSINFO;
        
        public string to_string () {
            switch (this) {
                case HOMEPAGE:
                    return "Home Page";
                case APPSVIEW:
                    return "Apps View";
                case APPSINFO:
                    return "Apps Info";
                default:
                    assert_not_reached();
            }
        }
        
        public PageType[] get_all () {
            return { HOMEPAGE, APPSVIEW, APPSINFO };
        }
    }
    
    // Apps Manager which handle the PackageKit connection
    public AppStore.AppsManager apps_manager;
    
    public class Frontend : Window {
        // Widgets
        public Box main_box;
        public Box info_box;
        public MainToolbar toolbar;
        public PagesView pages_view;
        public ProgressInfo progress_info;
        public InfoMessage info_message;
        
        // Vars
        private int _width = 0;
        
        public Frontend () {
            apps_manager = new AppStore.AppsManager("/var/cache/lsc-packages.db");
            
            destroy.connect(Gtk.main_quit);
            size_allocate.connect(on_size_allocate);
            
            window_position = WindowPosition.CENTER;
            title = "Cinnarch Software Center";
            icon_name = "system-software-installer";
            set_default_size(900, 600);
            has_resize_grip = true;
            main_box = new Box(Orientation.VERTICAL, 0);
            
            toolbar = new MainToolbar();
            main_box.pack_start(toolbar, false, false, 0);
            
            Overlay pages_overlay = new Overlay();
            
            progress_info = new ProgressInfo();
            info_message = new InfoMessage ();
            
            info_box = new Box (Orientation.VERTICAL, 0);
            info_box.hexpand = true;
            info_box.valign = Align.START;
            
            info_box.pack_start (info_message, false, false, 0);
            info_box.pack_start (progress_info, false, false, 0);
            
            pages_overlay.add_overlay (info_box);
            pages_view = new PagesView();
            pages_overlay.add (pages_view);
            
            main_box.pack_start(pages_overlay, true, true, 0);
            
            connect_signals();
            apps_manager.get_categories();
            
            add(main_box);
            show_all();
            
            info_message.set_visible (false);
            progress_info.set_visible(false);
            pages_view.apps_info.reviews_box.set_visible(false);
            info_box.set_visible (false);
            
            set_focus(null);
        }
        
        public void on_info_message_response (AppStore.ResponseId id, AppStore.ModelApp app) {
            switch (id) {
                case AppStore.ResponseId.INFO:
                    load_details (app);
                    break;
                case AppStore.ResponseId.INSTALL:
                    break;
            }
        }
        
        public void load_details (AppStore.ModelApp app) {
            info_message.set_visible (false);
            last_app = app;
            apps_manager.get_details (app);
            pages_view.set_page(PageType.APPSINFO);
        }
        
        public void load_packages (AppStore.Category category) {
            last_category = category;
            pages_view.set_page(PageType.APPSVIEW);
            pages_view.apps_view.apps_tree.clear();
            apps_manager.get_apps(category.id);
            toolbar.label.label = category.name;
            info_message.set_visible (false);
        }
        
        public void on_action_response (AppStore.ActionType type, string id) {
            switch (type) {
                case AppStore.ActionType.INSTALL:
                    apps_manager.install_packages ({id, null});
                    break;
                default:
                    apps_manager.remove_packages ({id, null}, true, false);
                    break;
            }
        }
        
        public void update_back_button (Notebook nb, Widget pg, uint page_n) {
            GLib.debug ("Page->%s\n", ((PageType) page_n).to_string());
            switch ((PageType) page_n) {
                case PageType.HOMEPAGE:
                    toolbar.searchbar.set_sensitive(true);
                    toolbar.label.margin_left = 5;
                    toolbar.back.set_visible(false);
                    break;
                
                case PageType.APPSINFO:
                    toolbar.searchbar.set_sensitive(false);
                    toolbar.label.margin_left = 0;
                    toolbar.back.set_visible(true);
                    break;
                
                default:
                    toolbar.searchbar.set_sensitive(true);
                    toolbar.label.margin_left = 0;
                    toolbar.back.set_visible(true);
                    break;
            }
        }
        
        public void back_to_homepage () {
            pages_view.apps_view.apps_tree.clear();
            pages_view.set_page(PageType.HOMEPAGE);
            info_box.set_visible (false);
        }
        
        public void connect_signals () {
            // When an app is added
            apps_manager.app_added.connect(pages_view.apps_view.apps_tree.append_app);
            // When something start loading
            apps_manager.loading_started.connect(on_load_started);
            // When something stop loading
            apps_manager.loading_finished.connect(on_load_finished);
            // When a transaction progress
            apps_manager.loading_progress.connect(progress_info.set_progress);
            // When a category is found in the database
            apps_manager.category_added.connect(pages_view.home_page.categories_view.add_category);
            // When a Details object is found from a package
            apps_manager.details_received.connect(pages_view.apps_info.set_details);
            // When either More Info or Install is pressed
            info_message.choosed.connect(on_info_message_response);
            // When a category is clicked
            pages_view.home_page.categories_view.category_choosed.connect(load_packages);
            // When an app is selected
            pages_view.apps_view.apps_tree.selected_row.connect((a) => {
                info_message.update (a);
                info_box.set_visible (true);
            });
            pages_view.apps_view.apps_tree.activated_row.connect((a) => {
                info_message.choosed (0, a);
            });
            // When the page is switched
            pages_view.switch_page.connect(update_back_button);
            pages_view.switch_page.connect(toolbar.update_label);
            // When back is clicked
            toolbar.back.button_press_event.connect(on_back_clicked);
            // When AppsInfo's action button is pressed
            pages_view.apps_info.action_response.connect (on_action_response);
        }
        
        public void rework_categories_columns (int width) {
            if (_width != width && width/160 != pages_view.home_page.categories_view.columns) {
                GLib.debug ("Window.width->%d rework columns\n", width);
                int size = width;
                if (size < 160 ) {
                    size = 160;
                }
                pages_view.home_page.categories_view.columns = size/150;
                
                _width = width;
            }
        }
        
        public void on_size_allocate (Allocation alloc) {
            if (pages_view.get_current_page() != PageType.HOMEPAGE) {
                return;
            }
            rework_categories_columns(alloc.width);
        }
        
        public bool on_back_clicked (Widget box, Gdk.EventButton button) {
            info_box.set_visible (false);
            switch (pages_view.get_current_page()) {
                case PageType.APPSVIEW:
                    back_to_homepage();
                    break;
                case PageType.APPSINFO:
                    pages_view.set_page (PageType.APPSVIEW);
                    info_message.set_visible (false);
                    break;
                default:
                    break;
            }
            
            return true;
        }
        
        public void on_load_started (AppStore.LoadingType load, string comment) {
            switch (load) {
                case AppStore.LoadingType.PACKAGES:
                    progress_info.load (comment);
                    break;
                case AppStore.LoadingType.DETAILS:
                    pages_view.apps_info.start_load();
                    break;
                case AppStore.LoadingType.INSTALL:
                    progress_info.load (comment);
                    break;
                case AppStore.LoadingType.REMOVE:
                    progress_info.load (comment);
                    break;
                default:
                    break;
            }
            info_box.set_visible (true);
        }
        
        public void on_load_finished (AppStore.LoadingType load) {
            switch (load) {
                case AppStore.LoadingType.CATEGORIES:
                    rework_categories_columns(get_allocated_width ());
                    break;
                case AppStore.LoadingType.PACKAGES:
                    progress_info.clear();
                    break;
                case AppStore.LoadingType.DETAILS:
                    progress_info.clear();
                    break;
                default:
                    progress_info.clear();
                    break;
            }
            info_box.set_visible (false);
        }
    }
}

int main (string[] args) {
    Gtk.init(ref args);
    new Lsc.Frontend();
    Gtk.main();
    return 0;
}
