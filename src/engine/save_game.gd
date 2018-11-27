extends Node

var save_data
var initial_save_data = {
    'level'      : 'levels/begining.tscn',
    'persistent' : {},
    'first_time' : true
}


var savegame_file = File.new()
var save_path = "user://savegame.bin"

func _write_to_file():
    savegame_file.open_encrypted_with_pass(save_path, File.WRITE, OS.get_unique_id())
    savegame_file.store_var(save_data)
    savegame_file.close()

func _read_from_file():
    savegame_file.open_encrypted_with_pass(save_path, File.READ, OS.get_unique_id())
    save_data = savegame_file.get_var()

"""
Loads save data from save game file
"""
func load_savegame():
    if not savegame_file.file_exists(save_path):
        print('[SaveGame] Loading from disk - NEW')
        save_data = initial_save_data.duplicate()
        _write_to_file()
    else:
        print('[SaveGame] Loading from disk - EXISTING')
        _read_from_file()
        
    return save_data
        
"""
Writes save_data to save game file
"""
func write_savegame():
    print('[SaveGame] Writing to disk')
    _write_to_file()

"""
Writes fresh save_data to save game file
"""
func delete_savegame():
    print('[SaveGame] Deleting from disk')
    save_data = initial_save_data.duplicate()
    _write_to_file()

"""
Stores all persistant nodes
"""
func store_savedata():
    save_data.persistent = {}
    save_data.first_time = false
    for node in get_tree().get_nodes_in_group("persistant"):
        save_data.persistent[node.name] = node.store_savedata()

"""
Restore all persitant nodes
"""
func restore_savedata(save_data):
    print('[SaveGame] Restoring from save_data')
    for node in get_tree().get_nodes_in_group("persistant"):
        if save_data.persistent.has(node.name):
            print('[SaveGame] RESTORING node as it was found in save_data: ', node.name)
            node.restore_savedata(save_data.persistent[node.name])
        elif not save_data.first_time:
            print('[SaveGame] DELETING node as not save_data and not first_time: ', node.name)
            # If not in saved data, delete
            node.queue_free()

"""
Stores level to save_data (not saved to disk!)
"""
func store_level(level):
    save_data.level = level.filename
    