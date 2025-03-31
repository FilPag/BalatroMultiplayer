-- Localization by @koukichi_kkc
-- 気になる点がありましたらサーバー内でもDMでもお気軽にご相談ください！
return {
	descriptions = {
		Joker = {
			j_broken = {
				name = "エラー",
				text = {
					"このカードは現在使用しているMODのバージョンでは未実装、",
					"またはデータが壊れている可能性があります",
				},
			},
			j_mp_defensive_joker = {
				name = "防御ジョーカー",
				text = {
					"相手より{C:red,E:1}ライフ{}が少ないとき、",
					"差1つにつきチップ {C:chips}+#1#{}",
					"{C:inactive}(現在 チップ {C:chips}+#2#{C:inactive})",
				},
			},
			j_mp_skip_off = {
				name = "おサボり",
				text = {
					"{C:attention}ブラインド{}をスキップした回数が",
					"{X:purple,C:white}相手{}と比べて1つ多くなる毎に",
					"ハンド {C:blue}+#1#{} ディスカード {C:red}+#2#{} ",
					"{C:inactive}(現在 {C:blue}+#3#{C:inactive}/{C:red}+#4#  {X:purple,C:white}相手{}{C:inactive}#5#)",
				},
			},
			j_mp_lets_go_gambling = {
				name = "Let’s ギャンブル！",
				text = {
					"{C:green}#2#分の#1#{} の確率で",
					"{X:mult,C:white}X#3#{}と{C:money}$#4#{}得る",
					"{C:green}#6#分の#5#{} の確率で",
					"{X:purple,C:white}相手{}に{C:money}$#7#{}が入る",
				},
			},
			j_mp_speedrun = {
				name = "タイムアタック",
				text = {
					"{X:purple,C:white}相手{}より先に{C:attention}PvPブラインド{}に",
					"到達した場合、{C:spectral}スペクトル{}カードを1つ作る",
					"{C:inactive}(空きが必要)",
				},
			},
			j_mp_conjoined_joker = {
				name = "結合ジョーカー",
				text = {
					"{C:attention}PvPブラインド{}で",
					"{X:purple,C:white}相手{} の残り{C:blue}ハンド{}1つにつき 倍率{X:mult,C:white}X#1#{}",
					"{C:inactive}(最大 倍率{X:mult,C:white}X#2#{C:inactive} , 現在 倍率{X:mult,C:white}X#3#{C:inactive})",
				},
			},
			j_mp_penny_pincher = {
				name = "ケチんぼ",
				text = {
					"ショップ開始時、{X:purple,C:white}相手{}が",
					"前回のショップで消費したお金 {C:money}$#2#{} ごとに {C:money}$#1#{} 得る",
				},
			},
			j_mp_taxes = {
				name = "税務係",
				text = {
					"{X:purple,C:white}相手{}がカードを売るたびに",
					"倍率 {C:mult}+#1#{} ",
					"{C:inactive}(現在 {C:mult}+#2#{C:inactive})",
				},
			},
			j_mp_magnet = {
				name = "マグネット",
				text = {
					"{C:attention}#1#{} ラウンド後",
					"このジョーカーを売ると",
					"{X:purple,C:white}相手{}の最も売値が高い{C:attention}ジョーカー{}を {C:attention}複製{} する",
					"{C:inactive}(現在 {C:attention}#2#{C:inactive}/#3#)",
					"{C:inactive,s:0.8}(エディションの状態は複製されません)",
				},
			},
			j_mp_pizza = {
				name = "ピッツァ",
				text = {
					"全員にディスカード {C:red}+#1#{}",
					"誰かがブラインドを選択するたびにディスカード {C:red}-#2#{} ",
					"{X:purple,C:white}相手{}がブラインドをスキップすると消滅する",
				},
			},
			j_mp_pacifist = {
				name = "平和主義者",
				text = {
					"{C:attention}PvPブラインドでない{} とき",
					"倍率 {X:mult,C:white}X#1#{}",
				},
			},
			j_mp_hanging_chad = {
				name = "ハンギングチャド",
				text = {
					"プレイしたカードで、",
					"{C:attention}最初{}と{C:attention}2番目に{}スコアされたものを",
					"再発動する",
					"アディショナルタイム {C:attention}#1#{}",
				},
			},
		},
		Planet = {
			c_mp_asteroid = {
				name = "小惑星",
				text = {
					"{X:purple,C:white}相手{}の",
					"一番高い{C:legendary,E:1} ポーカーハンド{}の",
					"レベルを #1# 下げる",
				},
			},
		},
		Blind = {
			bl_mp_nemesis = {
				name = "ライバル",
				text = {
					"スコアの高い方が勝ち！",
					"負けるとライフを1失う",
				},
			},
		},
		Edition = {
			e_mp_phantom = {
				name = "ファントム",
				text = {
					"{C:attention}エターナル{} と {C:dark_edition}ネガティブ{} を併せ持つ",
					"作成も破壊も{X:purple,C:white}相手{}にしかできない",
				},
			},
		},
		Enhanced = {
			m_mp_glass = {
				name = "グラスカード",
				text = {
					"{C:green}#3#分の#2#{} の確率で",
					"カードを破壊する",
					"倍率 {X:mult,C:white} X#1# {}",
				},
			},
		},
		Other = {
			current_nemesis = {
				name = "相手",
				text = {
					"{X:purple,C:white}#1#{}",
					"キミの唯一無二のライバルだ。",
				},
			},
		},
	},
	misc = {
		labels = {
			mp_phantom = "ファントム",
		},
		challenge_names = {
			c_mp_standard = "スタンダード",
			c_mp_badlatro = "Badlatro",
			c_mp_tournament = "トーナメント",
			c_mp_weekly = "ウィークリー",
			c_mp_vanilla = "バニラ",
		},
		dictionary = {
			b_singleplayer = "シングルプレイ",
			b_join_lobby = "ロビーに参加",
			b_return_lobby = "ロビーに戻る",
			b_reconnect = "再接続",
			b_create_lobby = "ロビーの作成",
			b_start_lobby = "このモードで作成",
			b_ready = "準備OK!",
			b_unready = "解除",
			b_leave_lobby = "ロビーから退出",
			b_mp_discord = "参加する",
			b_start = "スタート",
			b_wait_for_host_start = { "ゲーム開始を", "待っています" },
			b_wait_for_players = { "参加者を", "待っています" },
			b_lobby_options = "ロビー設定",
			b_copy_clipboard = "クリップボードにコピー",
			b_view_code = "ロビーID",
			b_leave = "ロビーから退出",
			b_opts_cb_money = "ライフ減少時に追加で$を受け取る",
			b_opts_no_gold_on_loss = "通常ラウンドでノルマ未達の場合にブラインド報酬を受け取らない",
			b_opts_death_on_loss = "通常ラウンドでノルマ未達の場合にライフを1失う",
			b_opts_start_antes = "PvP開始アンティ",
			b_opts_diff_seeds = "お互いに別シードでプレイ",
			b_opts_lives = "ライフ",
			b_opts_multiplayer_jokers = "マルチプレイオリジナルカードを有効",
			b_opts_player_diff_deck = "お互いに別デッキ 別ステークでプレイ",
			b_reset = "リセット",
			b_set_custom_seed = "シード値を指定",
			b_mp_kofi_button = "サポートページへ",
			b_unstuck = "詰み防止処置(β)",
			b_unstuck_arcana = "ﾌﾞｰｽﾀｰﾊﾟｯｸから出られなくなったとき",
			b_unstuck_blind = "PvPﾌﾞﾗｲﾝﾄﾞに進まなかったとき",
			k_enemy_score = "相手のスコア",
			k_enemy_hands = "相手の残りハンド ",
			k_coming_soon = "Coming Soon!",
			k_wait_enemy = "相手のプレイが終わるまでお待ちください...",
			k_lives = "ライフ",
			k_lost_life = "ライフ減少",
			k_total_lives_lost = " 失ったライフ数 (1つにつき$4)",
			k_attrition_name = "消耗戦",
			k_enter_lobby_code = "ロビーIDを入力",
			k_paste = "クリップボードからペースト",
			k_username = "ユーザーネーム:",
			k_enter_username = "ニックネームを入力",
			k_join_discord = "Balatro Multiplayer Discordサーバー",
			k_discord_msg = "バグ報告や対戦の申し込みはこちらから！",
			k_enter_to_save = "Enterで保存",
			k_in_lobby = "ロビー内",
			k_connected = "マルチプレイサービス接続済み",
			k_warn_service = "警告: マルチプレイサービスが見つかりません！",
			k_set_name = "メインメニューからニックネームを設定してください (Mods > Multiplayer > Config)",
			k_mod_hash_warning = "警告: 古いバージョンを利用しているため、場合によっては不具合が発生する可能性があります",
			k_lobby_options = "ロビー設定",
			k_connect_player = "参加者一覧",
			k_opts_only_host = "設定を変更できるのはホストのみです",
			k_opts_gm = "詳細設定",
			k_bl_life = "Life",
			k_bl_or = "or",
			k_bl_death = "Death",
			k_current_seed = "シード値: ",
			k_random = "ランダム",
			k_standard = "スタンダード",
			k_standard_description = "マルチプレイオリジナルカードやPvPブラインドが追加された標準的なルール\n(一部マルチ用にナーフされた通常カードがあります)",
			k_vanilla = "バニラ",
			k_vanilla_description = "マルチプレイオリジナルカードやPvPブラインド無しの通常ルール",
			k_weekly = "ウィークリー",
			k_weekly_description = "(ほぼ)毎週変わる特別なルール 何かは見てからのお楽しみ！",
			k_tournament = "トーナメント",
			k_tournament_description = "スタンダードと内容は同じですが、ロビー設定の変更が出来ません",
			k_badlatro = "Badlatro",
			k_badlatro_description = "DiscordサーバーでDr.Monty(@dr_monty_the_snek)さんが作成したルール。",
			k_oops_ex = "しまった!",
			ml_enemy_loc = { "相手の", "プレイ状況" },
			ml_mp_kofi_message = {
				"このMODは個人製作で成り立っています。",
				"気に入っていただけた方は、",
				"こちらからサポートを",
				"よろしくお願いします！",
			},
			loc_ready = "準備OK！",
			loc_selecting = "ブラインド選択",
			loc_shop = "ショップ",
			loc_playing = "",
		},
		v_dictionary = {
			a_mp_art = { "イラスト #1#" },
			a_mp_code = { "制作 #1#" },
			a_mp_idea = { "考案 #1#" },
			a_mp_skips_ahead = { "より#1#回多い" },
			a_mp_skips_behind = { "より#1#回少ない" },
			a_mp_skips_tied = { "と同数" },
		},
		v_text = {
			ch_c_hanging_chad_rework = { "{C:attention}ハンギングチャド{}は{C:dark_edition}マルチ用に改良されています。" },
			ch_c_glass_cards_rework = { "{C:attention}グラスカード{}は{C:dark_edition}マルチ用に改良されています。" },
		},
	},
}
