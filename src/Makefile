QCC=fteqcc

all:
	cd client && $(MAKE)
	cd server && $(MAKE)
	cd ../zpak001.pk3dir/maps/ && $(QCC) singleplayer.qc
	cd ../zpak001.pk3dir/maps/mp/gametypes && $(QCC) dm.qc
