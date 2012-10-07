namespace Menu {
    class MenuDir : Object {
		public string id { get; set; }
        public string name { get; set; }
        public string summary { get; set; }
        public string icon { get; set; }
        public string directory { get; set; }
        public string[] included;
        public string[] excluded;
        public int level;
        
        public void complete (KeyFile file) {
			summary = "";
			icon = "applications-other";
			try {
				file.load_from_file ("/usr/share/desktop-directories/%s".printf (directory), 0);
				name = file.get_string ("Desktop Entry", "Name");
				summary = file.get_string ("Desktop Entry", "Comment");
				icon = file.get_string ("Desktop Entry", "Icon");
				if (summary == null) {
					summary = "";
				}
				if (icon == null) {
					icon = "";
				}
			} catch (Error e) {
				GLib.debug ("Error retrieving data for %s: %s\n", directory, e.message);
			}
		}
        
        public MenuDir () {
            included = {};
            excluded = {};
        }
    }
    
    class MenuParser {
        private const MarkupParser parser = {
            opening_item,// when an element opens
            closing_item,  // when an element closes
            get_text, // when text is found
            null, // when comments are found
            null  // when errors occur
        };
        
        private string menu_file;
        private MarkupParseContext context;
        private MenuDir[] dirlist;
        private MenuDir[] dirs_level;
        private int level = 0;
        private string last_item;
        private bool include = true;
        private KeyFile file;
        
        public MenuDir[] parse () {
            string file;
            try {
				FileUtils.get_contents (menu_file, out file, null);
				context.parse (file, file.length);
			}
			catch(GLib.Error e) {
				GLib.error("Failed to parse file. %s\n", e.message);
			}
            
            return dirlist;
        }
        
        public MenuParser (string menu_file) {
            context = new MarkupParseContext(
                parser, // the structure with the callbacks
                0,      // MarkupParseFlags
                this,   // extra argument for the callbacks, methods in this case
                null // when the parsing ends
            );
            
            dirlist = {};
            dirs_level = {};
            this.menu_file = menu_file;
            file = new KeyFile();
        }
        
        void opening_item (MarkupParseContext context, string name, string[] attr, string[] vals) throws MarkupError {
            last_item = name;
            switch (name) {
                case "Menu":
                    MenuDir tmp = new MenuDir();
                    dirs_level[level] = tmp;
                    dirlist += tmp;
                    dirs_level[level].level = level;
                    level ++;
                    break;
                case "Not":
                    include = false;
                    break;
            }
        }
        
        void closing_item (MarkupParseContext context, string name) throws MarkupError {
            switch (name) {
                case "Menu":
                    level --;
                    dirs_level[level].complete (file);
                    break;
                case "Not":
                    include = true;
                    break;
            }
        }
        
        private bool check_whitespaces (string str) {
            return (str.strip() == "" ? true : false);
        }
        
        void get_text (MarkupParseContext context, string text, size_t text_len) throws MarkupError {
            if (check_whitespaces (text)) { return; }
            switch (last_item) {
                case "Name":
                    dirs_level[level-1].name = text;
                    dirs_level[level-1].id = text;
                    break;
                case "Directory":
                    dirs_level[level-1].directory = text;
                    break;
                case "Category":
                    if (include) {
                        dirs_level[level-1].included += text;
                    } else {
                        dirs_level[level-1].excluded += text;
                    }
                    break;
            }
        }
    }
}
