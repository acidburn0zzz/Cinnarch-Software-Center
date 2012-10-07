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

namespace Lsc.Widgets {
    public class ProgressInfo : InfoBar {
        // Widgets
        public Label text;
        public ProgressBar progress_bar;
        public Spinner spin;
        
        public void set_progress (int percentage) {
			if (progress_bar.get_fraction () != percentage / 100.0) {
				spin.set_visible (false);
				progress_bar.set_visible (true);
				progress_bar.set_fraction (percentage / 100.0);
			}
 	    }
        
        public void load (string label_text) {
            show_all();
            text.set_label(label_text);
            progress_bar.set_visible(false);
            spin.set_visible(true);
            spin.start();
        }
        
        public void clear () {
            spin.stop();
            progress_bar.set_fraction(0.0);
            set_visible(false);
        }
        
        public ProgressInfo () {
            message_type = MessageType.INFO;
            Box main = get_content_area() as Box;
            main.orientation = Orientation.HORIZONTAL;
            main.spacing = 2;
            orientation = Orientation.HORIZONTAL;
            
            text = new Label("");
            text.ellipsize = Pango.EllipsizeMode.END;
            
            progress_bar = new ProgressBar();
            progress_bar.pulse_step = 0.1;
            
            spin = new Spinner();
            
            main.pack_start(text, false, false, 0);
            main.pack_end(progress_bar, false, false, 0);
            main.pack_end(spin, false, false, 0);
        }
    }
}
