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

namespace Lsc.Widgets {
    public class InfoMessage : InfoBar {
        private uint timeout_id = 0;
        // Signals
        public signal void choosed (AppStore.ResponseId id, AppStore.ModelApp app);
        
        // Widgets
        public Label text;
        public Button info_button;
        public Button action_button;
        private AppStore.ModelApp current_app;
        
        public void update (AppStore.ModelApp app) {
            current_app = app;
            set_visible (true);
            text.set_label("Selected package <b>%s</b>".printf (app.id));
            
            if (timeout_id > 0)
                Source.remove (timeout_id);
            
            timeout_id = Timeout.add (2500, () => {
                set_visible (false);
                return false;
            });
        }
        
        public void get_response (InfoBar bar, int id) {
            choosed ((AppStore.ResponseId) id, current_app);
        }
        
        public InfoMessage () {
            message_type = MessageType.INFO;
            ((Box) get_action_area()).orientation = Orientation.HORIZONTAL;
            Box main = get_content_area() as Box;
            main.orientation = Orientation.HORIZONTAL;
            main.spacing = 2;
            orientation = Orientation.HORIZONTAL;
            
            text = new Label("");
            text.use_markup = true;
            text.ellipsize = Pango.EllipsizeMode.END;
            
            add_button(Stock.INFO, AppStore.ResponseId.INFO);
            
            main.pack_start(text, false, false, 0);
            
            response.connect (get_response);
        }
    }
}
