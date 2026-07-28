class_name RemotePrediction
extends RefCounted

# Keeps a projectile's locally predicted position instead of snapping it to
# every network snapshot. Snapshot data only refreshes immutable trajectory data.
static func merge_projectiles(current: Array[Dictionary], incoming: Array) -> Array[Dictionary]:
	var existing: Dictionary = {}
	for projectile in current:
		existing[projectile.id] = projectile
	var merged: Array[Dictionary] = []
	for snapshot in incoming:
		if existing.has(snapshot.id):
			var predicted: Dictionary = existing[snapshot.id]
			# Mystic arrows keep their initial firing vector. Replacing it every
			# snapshot made the rival's arrow bend or stop at the old target.
			if snapshot.kind != 4:
				predicted.target_position = snapshot.target_position
				predicted.direction = snapshot.direction
				predicted.speed = snapshot.speed
				predicted.kind = snapshot.kind
				predicted.remaining = max(predicted.remaining, snapshot.remaining)
			merged.append(predicted)
		else:
			merged.append(snapshot.duplicate(true))
	return merged
