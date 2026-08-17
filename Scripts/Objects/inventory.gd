extends Resource

class_name Inventory

signal update

@export var slots: Array[InvSlot]

#Create Inventory
func setup_inventory(size: int = 8):
	for i in range(size):
		var new_slot = InvSlot.new()
		slots.append(new_slot)

func insert(item: InvItem):
	var itemslots = slots.filter(func(slot): return slot.item == item)
	#Is this item already in a slot?
	if !itemslots.is_empty():
			itemslots[0].amount += 1
	#Is this item being placed in an empty slot?
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()
