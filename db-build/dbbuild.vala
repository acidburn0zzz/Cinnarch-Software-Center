
using PackageKit;
using SQLHeavy;
using Gtk; // Needed for icontheme support
using Menu;

class AppInstallPackage {
    public string[] directories { get; private set; }
    public string name { get; private set; }
    public string icon { get; set; }
    public string summary { get; set; }
    public string id { get; private set; }
    
    public AppInstallPackage (string[] directories, string name, string icon, string summary, string id) {
        this.directories = directories;
        this.name = name;
        this.icon = icon;
        this.summary = summary;
        this.id = id;
    }
}

class AppInstallDirectory {
	public string id { get; private set; }
    public string name { get; private set; }
    public string directory { get; private set; }
    
    public AppInstallDirectory (string id, string name, string directory) {
        this.name = name;
        this.directory = directory;
    }
}

class DbBuilder {
    private Dir root;
    private Transaction trans;
    private KeyFile keys;
    private string desktop_dir;
    private MenuDir[] menu_dirs;
    public Gee.HashMap<string, AppInstallPackage> packages;
    public IconTheme theme;
    
    public void add_pkg (Package pk, Transaction trs) {
        AppInstallPackage app_pkg = packages[pk.get_name()];
        if (app_pkg == null) { return; }
        if (app_pkg.summary == "") {
			app_pkg.summary = pk.get_summary();
		}
		if (app_pkg.icon == "" || ! theme.has_icon (app_pkg.icon)) {
			app_pkg.icon = "applications-other";
		}
        foreach (string dir in app_pkg.directories) {
	        GLib.debug ("Inserting %s in %s\n", app_pkg.id, dir);
	        Type t_string = typeof(string);
	        try {
				trs.execute_insert("INSERT INTO '%s' VALUES (:id, :name, :description, :icon);".printf (dir),
							   ":id", t_string, app_pkg.id,
							   ":name", t_string, app_pkg.name,
							   ":description", t_string, app_pkg.summary,
							   ":icon", t_string, app_pkg.icon);
				}
			catch(GLib.Error e) {
				GLib.error("Failed to insert values into database. %s", e.message);
			}
	    }
    }
    
    private string[] get_included_in (string[] categories) {
		string[] result = {};
		foreach (MenuDir dir in menu_dirs) {
			if (dir.level != 1) { continue; }
	        foreach (string cat in categories) {
	            if (cat in dir.excluded) {
					result = {};
	                break;
	            }
	            if (cat in dir.included && ! (dir.id in result) ) {
					result += dir.id;
				}
	        }
		}
        return result;
    }
    
    private string get_safe_key (string val) {
        try {
            return keys.get_string ("Desktop Entry", val);
        } catch (GLib.Error e) {
            GLib.debug ("Error retrieving key %s: %s\n", val, e.message);
        }
        return "";
    }
    
    private void get_apps () {
        root.rewind();
        string name;
        while ((name = root.read_name ()) != null) {
        if (! name.has_suffix (".desktop")) { continue; }
            try {
                keys.load_from_file (desktop_dir+name, 0);
                if (keys.has_key("Desktop Entry", "Categories") == false) { continue; }
                
                string[] categories = keys.get_string_list ("Desktop Entry", "Categories");
                string[] tmp_dirs = get_included_in (categories);
				AppInstallPackage pkg = new AppInstallPackage (tmp_dirs, get_safe_key ("Name"), get_safe_key ("Icon"), get_safe_key ("Comment"), get_safe_key ("X-AppInstall-Package"));
				packages.set (pkg.id, pkg);
            } catch {
                GLib.debug ("%s is not a valid .desktop file", name);
            }
        }
    }
    
    public DbBuilder (Database db, string menu_file) {
		theme = new IconTheme();
		theme.append_search_path ("/usr/share/app-install/icons/");
		
        packages = new Gee.HashMap<string, AppInstallPackage> ();
        
        desktop_dir = "/usr/share/app-install/desktop/";
        try {
			root = Dir.open (desktop_dir, 0);
		}
		catch(GLib.Error e) {
			GLib.error("Failed to open desktop directory: %s: %s", desktop_dir, e.message);
		}
        keys = new KeyFile ();
        
        MenuParser parser = new MenuParser (menu_file);
        
        try {
			trans = db.begin_transaction ();
		}
		catch(GLib.Error e) {
			GLib.error("Failed to start database transaction: %s", e.message);
		}
        
        stdout.printf ("Collecting app-install data...\n");
        try {
			trans.execute ("CREATE TABLE 'DIRECTORIES' (id, name, summary, icon, directory);");
		}
		catch(GLib.Error e) {
			GLib.error("Failed to create table DIRECTORIES: %s", e.message);
		}
        
        menu_dirs = parser.parse();
        
        foreach (MenuDir item in menu_dirs) {
            if (item.level == 1) { // We just want the Applications childs
				try {
					trans.execute ("CREATE TABLE '%s' (id, name, summary, icon);".printf (item.id));
					trans.execute ("INSERT INTO 'DIRECTORIES' VALUES (:id, :name, :summary, :icon, :directory);", 
                               ":id", typeof (string), item.id,
                               ":name", typeof (string), item.name,
                               ":summary", typeof (string), item.summary,
                               ":icon", typeof (string), item.icon,
                               ":directory", typeof (string), item.directory);
                }
                catch(GLib.Error e) {    
					GLib.error("Failed to create table %s: %s", item.id, e.message);
				}
            }
        }
        
        try {
            trans.commit();
        } catch (SQLHeavy.Error e) {
            GLib.error ("Error: %s\n", e.message);
        }
        
        get_apps ();
    }
}

Database db;
Client client;
DbBuilder dbbuilder;
Transaction trans;
Package[] pkgs;
string db_filename = null;
string menu_filename = null;

void pkg_received (Package pkg) {
	if (pkg != null) {
	    dbbuilder.add_pkg (pkg, trans);
	}
}

const OptionEntry[] entries = {
	{ "database", 'd', 0, OptionArg.FILENAME, ref db_filename, "Database file to build", null },
	{ "menu", 'm', 0, OptionArg.FILENAME, ref menu_filename, "Menu file to get categories from", null },
	{ null }
};

// FIXME: Awful OOP code

int main (string[] args) {
    pkgs = {};
    string[] ids = {};
    
    OptionContext context = new OptionContext ("Build a Lsc (Light Software Center) Database");
    context.add_main_entries (entries, null);
    
    try {
		context.parse (ref args);
	}
	catch(GLib.Error e) {
		GLib.error("Failed to parse options: %s", e.message);
	}
    
    if (db_filename == null) {
		GLib.error ("Specify a filename\n");
	}
	if (Environment.get_user_name () != "root") {
        GLib.error ("This program needs to be run as root!\n");
    }
    
    if (menu_filename == null) {
		menu_filename = "/usr/share/app-install/desktop/applications.menu";
	}
    
    FileUtils.remove ("/var/cache/lsc-vala.db");
    try {
		db = new Database ("/var/cache/lsc-vala.db");
	}
	catch(GLib.Error e) {
		GLib.error("Failed to create database: %s", e.message);
	}
    
    dbbuilder = new DbBuilder (db, menu_filename);
    
    client = new Client ();
    try {
		trans = db.begin_transaction ();
	}
	catch(GLib.Error e) {
		GLib.error("Failed to begin transaction: %s", e.message);
	}
    
    stdout.printf ("Querying PackageKit...\n");
    
    foreach (string s in dbbuilder.packages.keys) {
		ids += s;
	}
	ids += null;
    
    try {
        Results result = client.resolve(0, ids, null, null);
        result.get_package_array().foreach ((Func) pkg_received);
    } catch (GLib.Error e) {
        GLib.log ("Error!\n", LogLevelFlags.LEVEL_WARNING, e.message);
    }

    try {
        trans.commit();
    } catch (SQLHeavy.Error e) {
        GLib.error ("Error: %s\n", e.message);
    }
    
    stdout.printf ("Done, no error reported\n");
    
    return 0;
}
