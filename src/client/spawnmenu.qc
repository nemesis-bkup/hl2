void
Spawnlist_ToConbuffer(string spawnListPath)
{
	filestream spawnListFile = -1;
	string temp;
	int maxPerLine = 0;

	spawnListFile = fopen("settings/menu_props/random_crap.txt", FILE_READ);

	if (spawnListFile < 0) {
		return;
	}

	while ((temp = fgets(spawnListFile))) {
		int c = tokenize_console(temp);

		if (c == 2) {
			string nameString = argv(0);
			string modelPath = argv(1);
			string matPath =strcat("materials/gmod/", Util_ChangeExtension(modelPath, ""));
			con_printf(0, sprintf("^[\\img\\%s\\w\\64\\h\\64\\cmd\\propSpawn %S^]\n", matPath, modelPath));
			maxPerLine++;

			if (maxPerLine == 6) {
				con_printf(0, "\n");
				maxPerLine = 0;
			}
		}
	}
	con_printf(0, "\n");
}
