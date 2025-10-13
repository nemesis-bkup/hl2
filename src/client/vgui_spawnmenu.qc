/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

bool g_iSpawnMenuInitialized;

void VGUI_SpawnMenu ( void )
{
	static entity eModel;
	static vector vecDistance = [ 90, 0, 0 ];
	static vguiWindow winViewer;
	static vgui3DView viewModel;
	static vguiRect picBackground;
	static vguiList lstModels;
	static vguiScrollBar scrlModels;
	static vguiButton btnLoadModel;
	static vguiButton btnToolMode[29];
	
	// Renderer
	static vguiButton btnSpawnProp;
	
	static void VGUI_SpawnMenu_SetViewModel( void ) {
		if (pSeat == __NULL__) {
			return;
		}
		ncRenderableEntity theModel = (ncRenderableEntity)pSeat->m_eViewModel;
		ncRenderableEntity theModel2 = (ncRenderableEntity)pSeat->m_eViewModelL;

		if (theModel && theModel.classname == "vm") {
			theModel.modelindex = getmodelindex(eModel.model);
			theModel2.modelindex = 
			theModel2.modelindex2 = 
			theModel2.modelindex3 = 
			theModel2.modelindex4 =
			theModel.modelindex2 = 
			theModel.modelindex3 = 
			theModel.modelindex4 = 0;
			

			if (theModel) {
				theModel._UpdateBoneCount();
			}

			if (theModel2) {
				theModel2._UpdateBoneCount();
			}
		}
	}
	static void VGUI_SpawnMenu_Firstperson( void ) {
		vecDistance = [ 0, 0, 0 ];
		viewModel.Set3DAngles( [0,0,0] );
		viewModel.Set3DPos( [0,0,0] );
	}
	static void VGUI_SpawnMenu_ResetCam( void ) {
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));
		vecDistance = [ 90, 0, 0 ];
		viewModel.Set3DAngles( [0,180,0] );
		viewModel.Set3DPos( modelPos );

		makevectors( viewModel.Get3DAngles() );
		viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
	}
	static void VGUI_SpawnMenu_SpawnProp( void ) {
		/* in sandbox this may be allowed. */
		localcmd(sprintf("cmd propSpawn %S\n", eModel.model));
	}
	static void VGUI_SpawnMenu_SetFrame( int iFrame ) {
		float maxFrame = modelframecount(eModel.modelindex) - 1;
		eModel.frame = (float)iFrame;

		if (eModel.frame < 0) {
			eModel.frame = 0;
		}

		eModel.frame1time = 0;
	}

	static void VGUI_SpawnMenu_SetModel( string strModel ) {
		setmodel( eModel, strModel );
		VGUI_SpawnMenu_SetFrame( 0 );
		VGUI_SpawnMenu_ResetCam();
	}
	static void VGUI_SpawnMenu_Draw ( void ) {
		static int initialized = FALSE;
		if ( !initialized ) {
			initialized = TRUE;
			eModel = spawn();
			VGUI_SpawnMenu_SetModel( "models/error.vvm" );
		}
		addentity( eModel );
		eModel.frame1time += frametime;
		
		
		vector vert1, vert2, vert3, vert4;
		vector wireColor = [0.8f, 0.8f, 0.9f];

		vert1 = [16,0];
		vert2 = [0, 0];
		vert3 = [0, 16];
		vert4 = [16, 16];

		for (int x = -256; x < 256; x += 16) {
			for (int y = -256; y < 256; y += 16) {
				R_BeginPolygon( "" );
				R_PolygonVertex( [ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f );
				R_PolygonVertex( [ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f );
				R_EndPolygon();

				R_BeginPolygon( "" );
				R_PolygonVertex( [ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f );
				R_PolygonVertex( [ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f );
				R_EndPolygon();

				R_BeginPolygon( "" );
				R_PolygonVertex( [ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f );
				R_PolygonVertex( [ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f );
				R_EndPolygon();

				R_BeginPolygon( "" );
				R_PolygonVertex( [ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f );
				R_PolygonVertex( [ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f );
				R_EndPolygon();
			}
		}
	}
	static float VGUI_SpawnMenu_Input ( float flEVType, float flKey, float flChar, float flDevID ) {
		static int iMouseDrag = FALSE;
		static int iShiftDrag = FALSE;
		static vector vecDragOfs;
		vector vecDifference;
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));

		int iMouseOver =  Util_MouseAbove( getmousepos(), viewModel.m_parent.GetPos() + viewModel.GetPos(), viewModel.GetSize() );
		if ( flEVType == IE_KEYDOWN ) {
			if ( flKey == K_MOUSE1 && iMouseOver == TRUE ) {
				iMouseDrag = TRUE;
				vecDragOfs = getmousepos();
				return true;
			} else if ( flKey == K_MWHEELUP && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, --vecDistance[0], 512 );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				return true;
			} else if ( flKey == K_MWHEELDOWN && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, ++vecDistance[0], 512 );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				return true;
			} else if ( flKey == K_LSHIFT && iMouseOver == TRUE ) {
				iShiftDrag = TRUE;
			}
		} else if ( flEVType == IE_KEYUP ) {
			if ( flKey == K_MOUSE1 ) {
				iMouseDrag = FALSE;
			} else if ( flKey == K_LSHIFT ) {
				iShiftDrag = FALSE;
			}
		}

		if ( iMouseDrag == TRUE && iShiftDrag == FALSE ) {
			if ( flEVType == IE_MOUSEABS ) {
				vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
				viewModel.Set3DAngles( viewModel.Get3DAngles() + vecDifference );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				vecDragOfs = getmousepos();
				return true;
			}
		} else if ( iMouseDrag == TRUE && iShiftDrag == TRUE ) {
			if ( flEVType == IE_MOUSEABS ) {
				vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
				vecDistance[1] -= vecDifference[1];
				vecDistance[2] += vecDifference[0];
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				vecDragOfs = getmousepos();
				return true;
			}
		}
		return false;
	}
	static void VGUI_SpawnMenu_Resize ( void ) {
		// Resize the background and viewer
		vector vWinSize = winViewer.GetSize();
		

		lstModels.SetPos( [6, 64 ] );
		lstModels.SetSize( [172, (vWinSize[1]/2) - 64 ] );
		scrlModels.SetPos( lstModels.GetPos() + [ 172, 0 ] );
		scrlModels.SetLength( lstModels.GetSize()[1] );
		scrlModels.SetMax( lstModels.GetMaxVisibleItems() );

		picBackground.SetPos( lstModels.GetPos() + [0, lstModels.GetSize()[1] + 1] );
		picBackground.SetSize( lstModels.GetSize() + [20, 0]);
		viewModel.SetSize( picBackground.GetSize());
		viewModel.SetPos( picBackground.GetPos() );

		btnLoadModel.SetPos( viewModel.GetPos() + [ 0, viewModel.GetSize()[1] + 1 ] );
		btnSpawnProp.SetPos( btnLoadModel.GetPos() + [ 0, 30 ] );
	}
	
	static void VGUI_SpawnMenu_ScrollUpdate ( void ) {
		scrlModels.SetValue( lstModels.GetOffset() );
	}
	static void VGUI_SpawnMenu_ListUpdate ( void ) {
		lstModels.SetOffset( scrlModels.GetValue(), FALSE );
	}

	if ( !g_iSpawnMenuInitialized ) {
		g_iSpawnMenuInitialized = true;
		winViewer = spawn( vguiWindow );
		winViewer.SetTitle( "Spawn Menu" );
		winViewer.SetSize( [ 550, 390 ] );
		winViewer.SetMinSize( [ 430, 256 ] );
		winViewer.SetMaxSize( [ 9999, 9999 ] );
		winViewer.SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
		winViewer.SetPos( [ 172, 64 ] );
		winViewer.SetIcon( "gfx/icon16/world" );
		winViewer.CallOnResize( VGUI_SpawnMenu_Resize );

		picBackground = spawn( vguiRect );
		picBackground.SetPos( [ 6, 32 ] );

		viewModel = spawn( vgui3DView );
		viewModel.SetDrawFunc( VGUI_SpawnMenu_Draw );
		viewModel.SetInputFunc( VGUI_SpawnMenu_Input );
		viewModel.SetPos( [ 6, 32 ] );

		btnSpawnProp = spawn( vguiButton );
		btnSpawnProp.SetTitle( "Spawn Prop" );
		btnSpawnProp.SetFunc( VGUI_SpawnMenu_SpawnProp );
		btnSpawnProp.SetSize( [192,24] );
		
		searchhandle shModels = search_begin( "models/*.mdl:models/*.md2:models/*.vvm:models/*/*.mdl:models/*/*.md2:models/*/*.vvm:models/*/*/*.mdl:models/*/*/*.md2:models/*/*/*.vvm:models/*/*/*/*.mdl:models/*/*/*/*.md2:models/*/*/*/*.vvm", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
		lstModels = spawn( vguiList );
		lstModels.SetItemCount( search_getsize( shModels ) );
		lstModels.CallOnScroll( VGUI_SpawnMenu_ScrollUpdate );

		for ( int i = 0; i < search_getsize( shModels ); i++ ) {
			string strAdd = search_getfilename( shModels, i );
			lstModels.AddItem( substring( strAdd , 7, -1 ) );
		}
		search_end( shModels );
		
		scrlModels = spawn( vguiScrollBar );
		scrlModels.SetMin( 0 );
		scrlModels.SetStep( 1 );
		scrlModels.CallOnChange( VGUI_SpawnMenu_ListUpdate );

		static void VGUI_SpawnMenu_LoadSelected ( void ) {
			VGUI_SpawnMenu_SetModel( sprintf( "models/%s", lstModels.GetItem( lstModels.GetSelected() ) ) );
		}
		btnLoadModel = spawn( vguiButton );
		btnLoadModel.SetTitle( "Load Selected" );
		btnLoadModel.SetFunc( VGUI_SpawnMenu_LoadSelected );
		btnLoadModel.SetSize( [192,24] );

		VGUI_SpawnMenu_Resize();

		g_uiDesktop.Add( winViewer );
		winViewer.Add( picBackground );
		winViewer.Add( viewModel );
		winViewer.Add( lstModels );
		winViewer.Add( scrlModels );
		winViewer.Add( btnSpawnProp );
		winViewer.Add( btnLoadModel );
		
		int toolBtn = 0;
		for (int i = 0; i < 8; i++) {
			for (int x = 0; x < 4; x++) {
				float buttonWidth = 80;
				float buttonHeight = 24;
				vector newPos = scrlModels.GetPos() + [24 + (x * (buttonWidth+4)), (i * (buttonHeight+4))];
				btnToolMode[toolBtn] = spawn(vguiButton);
				btnToolMode[toolBtn].SetSize([buttonWidth,buttonHeight]);
				btnToolMode[toolBtn].SetPos(newPos);
				btnToolMode[toolBtn].SetTag(toolBtn);
				btnToolMode[toolBtn].SetTitle( localize(sprintf("#TOOL_BUTTON_%i", toolBtn)));
				btnToolMode[toolBtn].SetExec( sprintf("setinfo gm_toolmode %i\n", toolBtn) );
				winViewer.Add( btnToolMode[toolBtn] );
				toolBtn++;
				
				if (toolBtn >= GMTOOL_WHEELS) {
					break;
				}
			}
		}
	}

	winViewer.Show();
}
