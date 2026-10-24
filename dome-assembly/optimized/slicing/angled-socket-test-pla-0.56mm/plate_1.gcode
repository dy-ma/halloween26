; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 10m 29s; total estimated time: 16m 43s
; total layer number: 50
; total filament length [mm] : 3098.37
; total filament volume [cm^3] : 7452.46
; total filament weight [g] : 9.39
; filament_density: 1.26
; filament_diameter: 1.75
; max_z_height: 28.40
; filament: 1
; support_material_on_wipe_tower: 0
; HEADER_BLOCK_END

; CONFIG_BLOCK_START
; accel_to_decel_enable = 0
; accel_to_decel_factor = 50%
; activate_air_filtration = 0
; additional_cooling_fan_speed = 70
; additional_fan_full_speed_layer = 0
; alternate_extra_wall = 0
; ams_filament_load_time_ams = 0
; ams_filament_load_time_ams_lite = 0
; ams_filament_load_time_n3f_s = 0
; ams_filament_unload_time_ams = 0
; ams_filament_unload_time_ams_lite = 0
; ams_filament_unload_time_n3f_s = 0
; apply_scarf_seam_on_circles = 1
; auxiliary_fan = 0
; avoid_crossing_wall_includes_support = 0
; bed_custom_model = 
; bed_custom_texture = 
; bed_exclude_area = 
; bed_heat_soak_area = 
; bed_temperature_formula = by_first_filament
; before_layer_change_gcode = 
; best_object_pos = 0.5,0.5
; bottom_color_penetration_layers = 3
; bottom_shell_layers = 3
; bottom_shell_thickness = 0
; bottom_surface_density = 100%
; bottom_surface_pattern = monotonic
; bridge_angle = 0
; bridge_flow = 1
; bridge_no_support = 0
; bridge_speed = 30
; brim_object_gap = 0.1
; brim_type = no_brim
; brim_width = 5
; chamber_temperatures = 0
; change_filament_gcode = ;===== A1 20251031 =======================\nM1007 S0 ; turn off mass estimation\nG392 S0\nM620 S[next_extruder]A\nM204 S9000\nG1 Z{max_layer_z + 3.0} F1200\n\nM400\nM106 P1 S0\nM106 P2 S0\n{if old_filament_temp > 142 && next_extruder < 255}\nM104 S[old_filament_temp]\n{endif}\n\nG1 X267 F18000\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E-{retraction_distances_when_cut[previous_extruder]} F1200\n{else}\nM620.11 S0\n{endif}\nM400\n\nM620.1 E F{flush_volumetric_speeds[previous_extruder]/2.4053*60} T{flush_temperatures[previous_extruder]}\nM620.10 A0 F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nT[next_extruder]\nM620.1 E F{flush_volumetric_speeds[next_extruder]/2.4053*60} T{flush_temperatures[next_extruder]}\nM620.10 A1 F{flush_volumetric_speeds[next_extruder]/2.4053*60} L[flush_length] H[nozzle_diameter] T{flush_temperatures[next_extruder]}\n\nG1 Y128 F9000\n\n{if next_extruder < 255}\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM628 S1\nG92 E0\nG1 E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM400\nM629 S1\n{else}\nM620.11 S0\n{endif}\n\nM400\nG92 E0\nM628 S0\n\n{if flush_length_1 > 1}\n; FLUSH_START\n; always use highest temperature to flush\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S[flush_temperatures[next_extruder]]\nM106 P1 S60\n{if flush_length_1 > 23.7}\nG1 E23.7 F{flush_volumetric_speeds[previous_extruder]/2.4053*60} ; do not need pulsatile flushing for start part\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\n{else}\nG1 E{flush_length_1} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\n{endif}\n; FLUSH_END\nG1 E-[old_retract_length_toolchange] F1800\nG1 E[old_retract_length_toolchange] F300\nM400\nM1002 set_filament_type:{filament_type[next_extruder]}\n{endif}\n\n{if flush_length_1 > 45 && flush_length_2 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_2 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_2 > 45 && flush_length_3 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_3 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_3 > 45 && flush_length_4 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_4 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\n; FLUSH_END\n{endif}\n\nM629\n\nM400\nM106 P1 S60\nM109 S[new_filament_temp]\nG1 E6 F{flush_volumetric_speeds[next_extruder]/2.4053*60} ;Compensate for filament spillage during waiting temperature\nM400\nG92 E0\nG1 E-[new_retract_length_toolchange] F1800\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nG1 Z{max_layer_z + 3.0} F3000\nM106 P1 S0\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\n{else}\nG1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000\n{endif}\n\nM622.1 S0\nM9833 F{outer_wall_volumetric_speed/2.4} A0.3 ; cali dynamic extrusion compensation\nM1002 judge_flag filament_need_cali_flag\nM622 J1\n  G92 E0\n  G1 E-[new_retract_length_toolchange] F1800\n  M400\n  \n  M106 P1 S178\n  M400 S4\n  G1 X-38.2 F18000\n  G1 X-48.2 F3000\n  G1 X-38.2 F18000 ;wipe and shake\n  G1 X-48.2 F3000\n  G1 X-38.2 F12000 ;wipe and shake\n  G1 X-48.2 F3000\n  M400\n  M106 P1 S0 \nM623\n\nM621 S[next_extruder]A\nG392 S0\n\nM1007 S1\n
; circle_compensation_manual_offset = 0
; circle_compensation_speed = 200
; close_additional_fan_first_x_layers = 1
; close_fan_the_first_x_layers = 1
; compatible_printers_condition = 
; complete_print_exhaust_fan_speed = 70
; cool_plate_temp = 35
; cool_plate_temp_initial_layer = 35
; cooling_filter_enabled = 0
; cooling_perimeter_transition_distance = 10
; cooling_slowdown_logic = uniform_cooling
; counter_coef_1 = 0
; counter_coef_2 = 0.008
; counter_coef_3 = -0.041
; counter_limit_max = 0.033
; counter_limit_min = -0.035
; counterbore_hole_bridging = none
; curr_bed_type = Textured PEI Plate
; default_acceleration = 6000
; default_ams_type = -1
; default_filament_colour = ""
; default_filament_profile = "Bambu PLA Basic @BBL A1"
; default_jerk = 0
; default_nozzle_volume_type = Standard
; default_print_profile = 0.40mm Standard @BBL A1 0.8 nozzle
; deretraction_speed = 30
; detect_floating_vertical_shell = 1
; detect_narrow_internal_solid_infill = 1
; detect_overhang_wall = 1
; detect_thin_wall = 0
; diameter_limit = 50
; different_settings_to_system = ;;
; draft_shield = disabled
; during_print_exhaust_fan_speed = 70
; elefant_foot_compensation = 0.075
; embedding_wall_into_infill = 0
; enable_arc_fitting = 1
; enable_circle_compensation = 0
; enable_filament_dynamic_map = 0
; enable_height_slowdown = 0
; enable_long_retraction_when_cut = 2
; enable_mixed_color_sublayer = 0
; enable_order_independent_overlap_carving = 0
; enable_overhang_bridge_fan = 1
; enable_overhang_speed = 1
; enable_pre_heating = 0
; enable_pressure_advance = 0
; enable_prime_tower = 1
; enable_support = 0
; enable_support_ironing = 0
; enable_tower_interface_features = 0
; enable_wrapping_detection = 0
; enforce_support_layers = 0
; eng_plate_temp = 0
; eng_plate_temp_initial_layer = 0
; ensure_vertical_shell_thickness = enabled
; exclude_object = 1
; extruder_ams_count = 
; extruder_clearance_dist_to_rod = 56.5
; extruder_clearance_height_to_lid = 256
; extruder_clearance_height_to_rod = 25
; extruder_clearance_max_radius = 73
; extruder_colour = #018001
; extruder_max_nozzle_count = 1
; extruder_nozzle_stats = 
; extruder_offset = 0x0
; extruder_printable_area = 
; extruder_type = Direct Drive
; extruder_variant_list = "Direct Drive Standard"
; fan_cooling_layer_time = 80
; fan_direction = undefine
; fan_max_speed = 80
; fan_min_speed = 60
; farthest_point_timelapse = 0
; filament_adaptive_volumetric_speed = 0
; filament_adhesiveness_category = 100
; filament_bridge_speed = 25
; filament_change_length = 5
; filament_change_length_nc = 10
; filament_colour = #00AE42
; filament_cooling_before_tower = 0
; filament_cost = 19.99
; filament_density = 1.26
; filament_dev_ams_drying_ams_limitations = 1
; filament_dev_ams_drying_heat_distortion_temperature = 45
; filament_dev_ams_drying_temperature = 45
; filament_dev_ams_drying_time = 12
; filament_dev_chamber_drying_bed_temperature = 70
; filament_dev_chamber_drying_time = 12
; filament_dev_drying_cooling_temperature = 45
; filament_dev_drying_softening_temperature = 50
; filament_diameter = 1.75
; filament_enable_overhang_speed = 1
; filament_end_gcode = "; filament end gcode \n\n"
; filament_extruder_compatibility = 0
; filament_extruder_variant = "Direct Drive Standard"
; filament_flow_ratio = 0.98
; filament_flush_temp = 0
; filament_flush_temp_fast = 0
; filament_flush_volumetric_speed = 0
; filament_ids = GFA00
; filament_is_mixed = 0
; filament_is_support = 0
; filament_long_retractions_when_cut = 1
; filament_map = 1
; filament_map_2 = 0
; filament_map_mode = Auto For Flush
; filament_max_volumetric_speed = 21
; filament_metal_stickiness = None
; filament_minimal_purge_on_wipe_tower = 15
; filament_mixed_components = ""
; filament_mixed_gradient = 0
; filament_mixed_gradient_curve = ""
; filament_mixed_gradient_per_part = 0
; filament_mixed_gradient_range = ""
; filament_mixed_sublayer_ratios = ""
; filament_notes = 
; filament_nozzle_map = 0
; filament_overhang_1_4_speed = 0
; filament_overhang_2_4_speed = 50
; filament_overhang_3_4_speed = 30
; filament_overhang_4_4_speed = 10
; filament_overhang_totally_speed = 10
; filament_pre_cooling_temperature = 0
; filament_pre_cooling_temperature_nc = 0
; filament_preheat_temperature_delta = 0
; filament_prime_volume = 30
; filament_prime_volume_nc = 60
; filament_printable = 3
; filament_ramming_travel_time = 0
; filament_ramming_travel_time_nc = 0
; filament_ramming_volumetric_speed = -1
; filament_ramming_volumetric_speed_nc = -1
; filament_retract_length_nc = 14
; filament_retraction_distances_when_cut = 18
; filament_scarf_gap = 0%
; filament_scarf_height = 10%
; filament_scarf_length = 10
; filament_scarf_seam_type = none
; filament_self_index = 1
; filament_settings_id = "Bambu PLA Basic @BBL A1"
; filament_shrink = 100%
; filament_soluble = 0
; filament_start_gcode = "; filament start gcode\n{if  (bed_temperature[current_extruder] >55)||(bed_temperature_initial_layer[current_extruder] >55)}M106 P3 S200\n{elsif(bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}M106 P3 S150\n{elsif(bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S50\n{endif}\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}"
; filament_tower_interface_pre_extrusion_dist = 10
; filament_tower_interface_pre_extrusion_length = 0
; filament_tower_interface_print_temp = -1
; filament_tower_interface_purge_volume = 20
; filament_tower_ironing_area = 4
; filament_type = PLA
; filament_velocity_adaptation_factor = 1
; filament_vendor = "Bambu Lab"
; filament_volume_map = 0
; filename_format = {input_filename_base}_{filament_type[0]}_{print_time}.gcode
; fill_multiline = 1
; filter_out_gap_fill = 0
; first_layer_print_sequence = 0
; first_x_layer_fan_speed = 0
; first_x_layer_part_fan_speed = 0
; flush_into_infill = 0
; flush_into_objects = 0
; flush_into_support = 1
; flush_multiplier = 1
; flush_multiplier_fast = 1.2
; flush_volumes_matrix = 0,280,280,280,280,0,280,280,280,280,0,280,280,280,280,0
; flush_volumes_vector = 140,140,140,140,140,140,140,140
; full_fan_speed_layer = 0
; fuzzy_skin = none
; fuzzy_skin_first_layer = 0
; fuzzy_skin_mode = displacement
; fuzzy_skin_noise_type = classic
; fuzzy_skin_octaves = 4
; fuzzy_skin_persistence = 0.5
; fuzzy_skin_point_distance = 0.8
; fuzzy_skin_scale = 1
; fuzzy_skin_thickness = 0.3
; gap_infill_speed = 50
; gcode_add_line_number = 0
; gcode_flavor = marlin
; grab_length = 17.4
; group_algo_with_time = 0
; has_filament_switcher = 0
; has_scarf_joint_seam = 0
; head_wrap_detect_zone = 226x224,256x224,256x256,226x256
; hole_coef_1 = 0
; hole_coef_2 = -0.008
; hole_coef_3 = 0.23415
; hole_limit_max = 0.22
; hole_limit_min = 0.088
; hot_plate_temp = 65
; hot_plate_temp_initial_layer = 65
; hotend_cooling_rate = 2
; hotend_heating_rate = 2
; impact_strength_z = 13.8
; independent_support_layer_height = 1
; infill_combination = 0
; infill_direction = 45
; infill_instead_top_bottom_surfaces = 0
; infill_jerk = 9
; infill_lock_depth = 1
; infill_rotate_step = 0
; infill_shift_step = 0.4
; infill_wall_overlap = 15%
; inherits_group = ;;
; initial_layer_acceleration = 500
; initial_layer_flow_ratio = 1
; initial_layer_infill_speed = 55
; initial_layer_jerk = 9
; initial_layer_line_width = 0.82
; initial_layer_print_height = 0.4
; initial_layer_speed = 35
; initial_layer_travel_acceleration = 6000
; inner_wall_acceleration = 0
; inner_wall_jerk = 9
; inner_wall_line_width = 0.82
; inner_wall_speed = 150
; interface_shells = 0
; interlocking_beam = 0
; interlocking_beam_layer_count = 2
; interlocking_beam_width = 0.8
; interlocking_boundary_avoidance = 2
; interlocking_depth = 2
; interlocking_orientation = 22.5
; internal_bridge_support_thickness = 0.8
; internal_solid_infill_line_width = 0.82
; internal_solid_infill_pattern = zig-zag
; internal_solid_infill_speed = 150
; ironing_direction = 45
; ironing_fan_speed = -1
; ironing_flow = 10%
; ironing_inset = 0.41
; ironing_pattern = zig-zag
; ironing_spacing = 0.15
; ironing_speed = 30
; ironing_type = no ironing
; is_infill_first = 0
; layer_change_gcode = ; layer num/total_layer_count: {layer_num+1}/[total_layer_count]\n; update layer progress\nM73 L{layer_num+1}\nM991 S0 P{layer_num} ;notify layer change
; layer_height = 0.56
; line_width = 0.82
; locked_skeleton_infill_pattern = zigzag
; locked_skin_infill_pattern = crosszag
; long_retractions_when_cut = 0
; long_retractions_when_ec = 0
; machine_bed_mass_Y = 0
; machine_end_gcode = ;===== date: 20260513 =====================\nG392 S0 ;turn off nozzle clog detect\n\nM400 ; wait for buffer to clear\nG92 E0 ; zero the extruder\nG90\nG1 Z{max_layer_z + 0.4} F900 ; lower z a little\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\n{if !spiral_mode && print_sequence != \"by object\"}\nM1002 judge_flag timelapse_record_flag\nM622 J1\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM991 S0 P-1 ;end timelapse at safe pos\nM623\n{endif}\n\nM140 S0 ; turn off bed\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off remote part cooling fan\nM106 P3 S0 ; turn off chamber cooling fan\n\n;G1 X27 F15000 ; wipe\n\n; pull back filament to AMS\nM620 S255\nG1 X267 F15000\nT255\nG1 X-28.5 F18000\nG1 X-48.2 F3000\nG1 X-28.5 F18000\nG1 X-48.2 F3000\nM621 S255\n\nM104 S0 ; turn off hotend\n\nM400 ; wait all motion done\nM17 S\nM17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom\n{if (max_layer_z + 100.0) < 256}\n    G1 Z{max_layer_z + 100.0} F600\n    G1 Z{max_layer_z +98.0}\n{else}\n    G1 Z256 F600\n    G1 Z256\n{endif}\nM400 P100\nM17 R ; restore z current\n\nG90\nG1 X-48 Y180 F3600\n\nM220 S100  ; Reset feedrate magnitude\nM201.2 K1.0 ; Reset acc magnitude\nM73.2   R1.0 ;Reset left time magnitude\nM1002 set_gcode_claim_speed_level : 0\n\n;=====printer finish  sound=========\nM17\nM400 S1\nM1006 S1\nM1006 A0 B20 L100 C37 D20 M40 E42 F20 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C46 D10 M80 E46 F10 N80\nM1006 A44 B20 L100 C39 D20 M60 E48 F20 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C39 D10 M60 E39 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C39 D10 M60 E39 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C48 D10 M60 E44 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10  N80\nM1006 A44 B20 L100 C49 D20 M80 E41 F20 N80\nM1006 A0 B20 L100 C0 D20 M60 E0 F20 N80\nM1006 A0 B20 L100 C37 D20 M30 E37 F20 N60\nM1006 W\n;=====printer finish  sound=========\n\n;M17 X0.8 Y0.8 Z0.5 ; lower motor current to 45% power\nM400\nM18 X Y Z\n\n
; machine_hotend_change_time = 0
; machine_load_filament_time = 25
; machine_max_acceleration_e = 5000,5000
; machine_max_acceleration_extruding = 12000,12000
; machine_max_acceleration_retracting = 5000,5000
; machine_max_acceleration_travel = 6000,6000
; machine_max_acceleration_x = 6000,6000
; machine_max_acceleration_y = 6000,6000
; machine_max_acceleration_z = 1500,1500
; machine_max_force_Y = 0
; machine_max_jerk_e = 3,3
; machine_max_jerk_x = 9,9
; machine_max_jerk_y = 9,9
; machine_max_jerk_z = 3,3
; machine_max_printed_mass = 0
; machine_max_speed_e = 30,30
; machine_max_speed_x = 500,200
; machine_max_speed_y = 500,200
; machine_max_speed_z = 30,30
; machine_min_extruding_rate = 0,0
; machine_min_travel_rate = 0,0
; machine_pause_gcode = M400 U1
; machine_prepare_compensation_time = 260
; machine_start_gcode = ;===== machine: A1 =========================\n;===== date: 20260513 ==================\nG392 S0\nM9833.2\n;M400\n;M73 P1.717\n\n;===== start to heat heatbead&hotend==========\nM1002 gcode_claim_action : 2\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM104 S140\nM140 S[bed_temperature_initial_layer_single]\n\n;=====start printer sound ===================\nM17\nM400 S1\nM1006 S1\nM1006 A0 B10 L100 C37 D10 M60 E37 F10 N60\nM1006 A0 B10 L100 C41 D10 M60 E41 F10 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A43 B10 L100 C46 D10 M70 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C43 D10 M60 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C41 D10 M80 E41 F10 N80\nM1006 A0 B10 L100 C44 D10 M80 E44 F10 N80\nM1006 A0 B10 L100 C49 D10 M80 E49 F10 N80\nM1006 A0 B10 L100 C0 D10 M80 E0 F10 N80\nM1006 A44 B10 L100 C48 D10 M60 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C44 D10 M80 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A43 B10 L100 C46 D10 M60 E39 F10 N80\nM1006 W\nM18 \n;=====start printer sound ===================\n\n;=====avoid end stop =================\nG91\nG380 S2 Z40 F1200\nG380 S3 Z-15 F1200\nG90\n\n;===== reset machine status =================\n;M290 X39 Y39 Z8\nM204 S6000\n\nM630 S0 P0\nG91\nM17 Z0.3 ; lower the z-motor current\n\nG90\nM17 X0.65 Y1.2 Z0.6 ; reset motor current to default\nM960 S5 P1 ; turn on logo lamp\nG90\nM220 S100 ;Reset Feedrate\nM221 S100 ;Reset Flowrate\nM73.2   R1.0 ;Reset left time magnitude\n;M211 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem\n\n;====== cog noise reduction=================\nM982.2 S1 ; turn on cog noise reduction\n\nM1002 gcode_claim_action : 13\n\nG28 X\nG91\nG1 Z5 F1200\nG90\nG0 X128 F30000\nG0 Y254 F3000\nG91\nG1 Z-5 F1200\n\nM109 S25 H140\n\nM17 E0.3\nM83\nG1 E10 F1200\nG1 E-0.5 F30\nM17 D\n\nG28 Z P0 T140; home z with low precision,permit 300deg temperature\nM104 S{nozzle_temperature_initial_layer[initial_extruder]}\n\nM1002 judge_flag build_plate_detect_flag\nM622 S1\n  G39.4\n  G90\n  G1 Z5 F1200\nM623\n\n;M400\n;M73 P1.717\n\n;===== prepare print temperature and material ==========\nM1002 gcode_claim_action : 24\n\nM400\n;G392 S1\nM211 X0 Y0 Z0 ;turn off soft endstop\nM975 S1 ; turn on\n\nG90\nG1 X-28.5 F30000\nG1 X-48.2 F3000\n\nM620 M ;enable remap\nM620 S[initial_no_support_extruder]A   ; switch material if AMS exist\n    M1002 gcode_claim_action : 4\n    M400\n    M1002 set_filament_type:UNKNOWN\n    M109 S[nozzle_temperature_initial_layer]\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M104 S220\n{else}\n    M104 S250\n{endif}\n    M400\n    T[initial_no_support_extruder]\n    G1 X-48.2 F3000\n    M400\n\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T220\n    M109 S220 ;set nozzle to common flush temp\n{else}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T{flush_temperatures[initial_no_support_extruder]}\n    M109 S250 ;set nozzle to common flush temp\n{endif}\n    M106 P1 S0\n    G92 E0\n    G1 E50 F200\n    M400\n    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM621 S[initial_no_support_extruder]A\n\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M109 S220 H300\n{else}\n    M109 S{flush_temperatures[initial_no_support_extruder]} H300\n{endif}\nG92 E0\nG1 E50 F200 ; lower extrusion speed to avoid clog\nM400\nM106 P1 S178\nG92 E0\nG1 E5 F200\nM104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]}\nG92 E0\nG1 E-0.5 F300\n\nG1 X-28.5 F30000\nG1 X-48.2 F3000\nG1 X-28.5 F30000 ;wipe and shake\nG1 X-48.2 F3000\nG1 X-28.5 F30000 ;wipe and shake\nG1 X-48.2 F3000\n\n;G392 S0\n\nM400\nM106 P1 S0\n;===== prepare print temperature and material end =====\n\n;M400\n;M73 P1.717\n\n;===== auto extrude cali start =========================\nM975 S1\n;G392 S1\n\nG90\nM83\nT1000\nG1 X-48.2 Y0 Z10 F10000\nM400\nM1002 set_filament_type:UNKNOWN\n\nM412 S1 ;  ===turn on  filament runout detection===\nM400 P10\nM620.3 W1; === turn on filament tangle detection===\nM400 S2\n\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n\n;M1002 set_flag extrude_cali_flag=1\nM1002 judge_flag extrude_cali_flag\n\nM622 J1\n    M1002 gcode_claim_action : 8\n\n    M109 S{nozzle_temperature[initial_extruder]}\n    G1 E10 F{outer_wall_volumetric_speed/2.4*60}\n    M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n\n    M106 P1 S255\n    M400 S5\n    G1 X-28.5 F18000\n    G1 X-48.2 F3000\n    G1 X-28.5 F18000 ;wipe and shake\n    G1 X-48.2 F3000\n    G1 X-28.5 F12000 ;wipe and shake\n    G1 X-48.2 F3000\n    M400\n    M106 P1 S0\n\n    M1002 judge_last_extrude_cali_success\n    M622 J0\n        M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n        M106 P1 S255\n        M400 S5\n        G1 X-28.5 F18000\n        G1 X-48.2 F3000\n        G1 X-28.5 F18000 ;wipe and shake\n        G1 X-48.2 F3000\n        G1 X-28.5 F12000 ;wipe and shake\n        M400\n        M106 P1 S0\n    M623\n    \n    G1 X-48.2 F3000\n    M400\n    M984 A0.1 E1 S1 F{outer_wall_volumetric_speed/2.4} H[nozzle_diameter]\n    M106 P1 S178\n    M400 S7\n    G1 X-28.5 F18000\n    G1 X-48.2 F3000\n    G1 X-28.5 F18000 ;wipe and shake\n    G1 X-48.2 F3000\n    G1 X-28.5 F12000 ;wipe and shake\n    G1 X-48.2 F3000\n    M400\n    M106 P1 S0\nM623 ; end of \"draw extrinsic para cali paint\"\n\n;G392 S0\n;===== auto extrude cali end ========================\n\n;M400\n;M73 P1.717\n\nM104 S170 ; prepare to wipe nozzle\nM106 S255 ; turn on fan\n\n;===== mech mode fast check start =====================\nM1002 gcode_claim_action : 3\n\nG1 X128 Y128 F20000\nG1 Z5 F1200\nM400 P200\nM970.3 Q1 A5 K0 O3\nM974 Q1 S2 P0\n\nM970.2 Q1 K1 W58 Z0.1\nM974 S2\n\nG1 X128 Y128 F20000\nG1 Z5 F1200\nM400 P200\nM970.3 Q0 A10 K0 O1\nM974 Q0 S2 P0\n\nM970.2 Q0 K1 W78 Z0.1\nM974 S2\n\nM975 S1\nG1 F30000\nG1 X0 Y5\nG28 X ; re-home XY\n\nG1 Z4 F1200\n\n;===== mech mode fast check end =======================\n\n;M400\n;M73 P1.717\n\n;===== wipe nozzle ===============================\nM1002 gcode_claim_action : 14\n\nM975 S1\nM106 S255 ; turn on fan (G28 has turn off fan)\nM211 S; push soft endstop status\nM211 X0 Y0 Z0 ;turn off Z axis endstop\n\n;===== remove waste by touching start =====\n\nM104 S170 ; set temp down to heatbed acceptable\n\nM83\nG1 E-1 F500\nG90\nM83\n\nM109 S170\nG0 X108 Y-0.5 F30000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X110 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X112 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X114 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X116 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X118 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X120 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X122 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X124 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X126 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X128 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X130 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X132 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X134 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X136 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X138 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X140 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X142 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X144 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X146 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X148 F10000\nG380 S3 Z-5 F1200\n\nG1 Z5 F30000\n;===== remove waste by touching end =====\n\nG1 Z10 F1200\nG0 X118 Y261 F30000\nG1 Z5 F1200\nM109 S{nozzle_temperature_initial_layer[initial_extruder]-50}\n\nG28 Z P0 T300; home z with low precision,permit 300deg temperature\nG29.2 S0 ; turn off ABL\nM104 S140 ; prepare to abl\nG0 Z5 F20000\n\nG0 X128 Y261 F20000  ; move to exposed steel surface\nG0 Z-1.01 F1200      ; stop the nozzle\n\nG91\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nG90\nG1 Z10 F1200\n\n;===== brush material wipe nozzle =====\n\nG90\nG1 Y250 F30000\nG1 X55\nG1 Z1.300 F1200\nG1 Y262.5 F6000\nG91\nG1 X-35 F30000\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Z5.000 F1200\n\nG90\nG1 X30 Y250.000 F30000\nG1 Z1.300 F1200\nG1 Y262.5 F6000\nG91\nG1 X35 F30000\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Z10.000 F1200\n\n;===== brush material wipe nozzle end =====\n\nG90\n;G0 X128 Y261 F20000  ; move to exposed steel surface\nG1 Y250 F30000\nG1 X138\nG1 Y261\nG0 Z-1.01 F1200      ; stop the nozzle\n\nG91\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nM109 S140\nM106 S255 ; turn on fan (G28 has turn off fan)\n\nM211 R; pop softend status\n\n;===== wipe nozzle end ================================\n\n;M400\n;M73 P1.717\n\n;===== bed leveling ==================================\nM1002 judge_flag g29_before_print_flag\n\nG90\nG1 Z5 F1200\nG1 X0 Y0 F30000\nG29.2 S1 ; turn on ABL\n\nM190 S[bed_temperature_initial_layer_single]; ensure bed temp\nM109 S140\nM106 S0 ; turn off fan , too noisy\n\nM622 J1\n    M1002 gcode_claim_action : 1\n    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}\n    M400\n    M500 ; save cali data\nM623\n;===== bed leveling end ================================\n\n;===== home after wipe mouth============================\nM1002 judge_flag g29_before_print_flag\nM622 J0\n\n    M1002 gcode_claim_action : 13\n    G28\n\nM623\n\n;===== home after wipe mouth end =======================\n\n;M400\n;M73 P1.717\n\nG1 X108.000 Y-0.500 F30000\nG1 Z0.300 F1200\nM400\nG2814 Z0.32\n\nM104 S{nozzle_temperature_initial_layer[initial_extruder]} ; prepare to print\n\n;===== nozzle load line ===============================\n;G90\n;M83\n;G1 Z5 F1200\n;G1 X88 Y-0.5 F20000\n;G1 Z0.3 F1200\n\n;M109 S{nozzle_temperature_initial_layer[initial_extruder]}\n\n;G1 E2 F300\n;G1 X168 E4.989 F6000\n;G1 Z1 F1200\n;===== nozzle load line end ===========================\n\n;===== extrude cali test ===============================\n\nM400\n    M900 S\n    M900 C\n    G90\n    M83\n\n    M109 S{nozzle_temperature_initial_layer[initial_extruder]}\n    G0 X128 E8  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G91\n    G1 X1 Z-0.300\n    G1 X4\n    G1 Z1 F1200\n    G90\n    M400\n\nM900 R\n\nM1002 judge_flag extrude_cali_flag\nM622 J1\n    G90\n    G1 X108.000 Y1.000 F30000\n    G91\n    G1 Z-0.700 F1200\n    G90\n    M83\n    G0 X128 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G91\n    G1 X1 Z-0.300\n    G1 X4\n    G1 Z1 F1200\n    G90\n    M400\nM623\n\nG1 Z0.2\n\n;M400\n;M73 P1.717\n\n;========turn off light and wait extrude temperature =============\nM1002 gcode_claim_action : 0\nM400\n\n;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==\n;curr_bed_type={curr_bed_type}\n{if curr_bed_type==\"Textured PEI Plate\"}\nG29.1 Z{-0.02} ; for Textured PEI Plate\n{endif}\n\nM960 S1 P0 ; turn off laser\nM960 S2 P0 ; turn off laser\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off big fan\nM106 P3 S0 ; turn off chamber fan\n\nM975 S1 ; turn on mech mode supression\nG90\nM83\nT1000\n\nM211 X0 Y0 Z0 ;turn off soft endstop\n;G392 S1 ; turn on clog detection\nM1007 S1 ; turn on mass estimation\nG29.4\n
; machine_switch_extruder_time = 0
; machine_unload_filament_time = 29
; master_extruder_id = 1
; max_bridge_length = 0
; max_layer_height = 0.56
; max_travel_detour_distance = 0
; min_bead_width = 85%
; min_feature_size = 25%
; min_layer_height = 0.16
; minimum_sparse_infill_area = 15
; mmu_segmented_region_interlocking_depth = 0
; mmu_segmented_region_max_width = 0
; monotonic_travel_into_wall = 0%
; no_slow_down_for_cooling_on_outwalls = 0
; nozzle_diameter = 0.8
; nozzle_flush_dataset = 0
; nozzle_height = 4.76
; nozzle_temperature = 220
; nozzle_temperature_initial_layer = 220
; nozzle_temperature_range_high = 240
; nozzle_temperature_range_low = 190
; nozzle_type = stainless_steel
; nozzle_volume = 92
; nozzle_volume_type = Standard
; only_one_wall_first_layer = 0
; ooze_prevention = 0
; other_layers_print_sequence = 0
; other_layers_print_sequence_nums = 0
; outer_wall_acceleration = 5000
; outer_wall_jerk = 9
; outer_wall_line_width = 0.82
; outer_wall_speed = 120
; overhang_1_4_speed = 0
; overhang_2_4_speed = 50
; overhang_3_4_speed = 25
; overhang_4_4_speed = 5
; overhang_fan_speed = 100
; overhang_fan_threshold = 50%
; overhang_threshold_participating_cooling = 95%
; overhang_totally_speed = 10
; override_filament_scarf_seam_setting = 0
; override_process_overhang_speed = 0
; physical_extruder_map = 0
; post_process = 
; pre_start_fan_time = 2
; precise_outer_wall = 0
; precise_z_height = 0
; pressure_advance = 0.02
; prime_tower_brim_width = 3
; prime_tower_enable_framework = 0
; prime_tower_extra_rib_length = 0
; prime_tower_fillet_wall = 1
; prime_tower_flat_ironing = 0
; prime_tower_infill_gap = 150%
; prime_tower_lift_height = -1
; prime_tower_lift_speed = 90
; prime_tower_max_speed = 90
; prime_tower_rib_wall = 1
; prime_tower_rib_width = 8
; prime_tower_skip_points = 1
; prime_tower_width = 35
; prime_volume_mode = Default
; print_compatible_printers = "Bambu Lab A1 0.8 nozzle"
; print_extruder_id = 1
; print_extruder_variant = "Direct Drive Standard"
; print_flow_ratio = 1
; print_in_clockwise = 0
; print_sequence = by layer
; print_settings_id = 0.56mm Extra Draft @BBL A1 0.8 nozzle
; printable_area = 0x0,256x0,256x256,0x256
; printable_height = 256
; printer_extruder_id = 1
; printer_extruder_variant = "Direct Drive Standard"
; printer_model = Bambu Lab A1
; printer_notes = 
; printer_settings_id = Bambu Lab A1 0.8 nozzle
; printer_structure = i3
; printer_technology = FFF
; printer_variant = 0.8
; printing_by_object_gcode = 
; process_notes = 
; raft_contact_distance = 0.1
; raft_expansion = 1.5
; raft_first_layer_density = 90%
; raft_first_layer_expansion = -1
; raft_layers = 0
; reduce_crossing_wall = 0
; reduce_fan_stop_start_freq = 1
; reduce_infill_retraction_mode = Auto
; required_nozzle_HRC = 3
; resolution = 0.012
; retract_before_wipe = 0%
; retract_length_toolchange = 2
; retract_lift_above = 0
; retract_lift_below = 255
; retract_restart_extra = 0
; retract_restart_extra_toolchange = 0
; retract_when_changing_layer = 1
; retraction_distances_when_cut = 18
; retraction_distances_when_ec = 0
; retraction_length = 0.8
; retraction_minimum_travel = 1
; retraction_speed = 30
; role_base_wipe_speed = 1
; scan_first_layer = 0
; scarf_angle_threshold = 155
; seam_gap = 15%
; seam_placement_away_from_overhangs = 0
; seam_position = aligned
; seam_slope_conditional = 1
; seam_slope_entire_loop = 0
; seam_slope_gap = 0
; seam_slope_inner_walls = 1
; seam_slope_min_length = 10
; seam_slope_start_height = 10%
; seam_slope_steps = 10
; seam_slope_type = none
; silent_mode = 0
; single_extruder_multi_material = 1
; skeleton_infill_density = 15%
; skeleton_infill_line_width = 0.82
; skin_infill_density = 15%
; skin_infill_depth = 2
; skin_infill_line_width = 0.82
; skirt_distance = 2
; skirt_height = 1
; skirt_loops = 0
; skirt_per_object = 1
; slice_closing_radius = 0.049
; slicing_mode = regular
; slow_down_for_layer_cooling = 1
; slow_down_layer_time = 6
; slow_down_min_speed = 20
; slowdown_end_acc = 100000
; slowdown_end_height = 400
; slowdown_end_speed = 1000
; slowdown_start_acc = 100000
; slowdown_start_height = 0
; slowdown_start_speed = 1000
; small_perimeter_speed = 50%
; small_perimeter_threshold = 0
; smooth_coefficient = 80
; smooth_speed_discontinuity_area = 1
; solid_infill_filament = 0
; sparse_infill_acceleration = 100%
; sparse_infill_anchor = 400%
; sparse_infill_anchor_max = 20
; sparse_infill_density = 15%
; sparse_infill_filament = 0
; sparse_infill_lattice_angle_1 = -45
; sparse_infill_lattice_angle_2 = 45
; sparse_infill_line_width = 0.82
; sparse_infill_pattern = grid
; sparse_infill_speed = 100
; spiral_mode = 0
; spiral_mode_max_xy_smoothing = 200%
; spiral_mode_smooth = 0
; standby_temperature_delta = -5
; start_end_points = 30x-3,54x245
; supertack_plate_temp = 45
; supertack_plate_temp_initial_layer = 45
; support_air_filtration = 0
; support_angle = 0
; support_base_pattern = default
; support_base_pattern_spacing = 2.5
; support_bottom_interface_spacing = 0.5
; support_bottom_z_distance = 0.2
; support_chamber_temp_control = 0
; support_cooling_filter = 0
; support_critical_regions_only = 0
; support_expansion = 0
; support_fast_purge_mode = 0
; support_filament = 0
; support_interface_bottom_layers = 2
; support_interface_filament = 0
; support_interface_loop_pattern = 0
; support_interface_not_for_body = 1
; support_interface_pattern = auto
; support_interface_spacing = 0.5
; support_interface_speed = 80
; support_interface_top_layers = 2
; support_ironing_direction = 0
; support_ironing_flow = 10%
; support_ironing_inset = 0
; support_ironing_pattern = zig-zag
; support_ironing_spacing = 0.15
; support_ironing_speed = 30
; support_line_width = 0.82
; support_object_first_layer_gap = 0.2
; support_object_skip_flush = 0
; support_object_xy_distance = 0.35
; support_on_build_plate_only = 0
; support_remove_small_overhang = 1
; support_speed = 150
; support_style = default
; support_threshold_angle = 30
; support_top_z_distance = 0.2
; support_type = tree(auto)
; symmetric_infill_y_axis = 0
; temperature_vitrification = 45
; template_custom_gcode = 
; textured_plate_temp = 65
; textured_plate_temp_initial_layer = 65
; thick_bridges = 0
; thumbnail_size = 50x50
; time_lapse_gcode = ;===================== date: 20250206 =====================\n{if !spiral_mode && print_sequence != \"by object\"}\n; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer\n; SKIPPABLE_START\n; SKIPTYPE: timelapse\nM622.1 S1 ; for prev firmware, default turned on\nM1002 judge_flag timelapse_record_flag\nM622 J1\nG92 E0\nG1 Z{max_layer_z + 0.4}\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-48.2 F3000 ; move to safe pos\nM400\nM1004 S5 P1  ; external shutter\nM400 P300\nM971 S11 C11 O0\nG92 E0\nG1 X0 F18000\nM623\n\n; SKIPTYPE: head_wrap_detect\nM622.1 S1\nM1002 judge_flag g39_3rd_layer_detect_flag\nM622 J1\n    ; enable nozzle clog detect at 3rd layer\n    {if layer_num == 2}\n      M400\n      G90\n      M83\n      M204 S5000\n      G0 Z2 F4000\n      G0 X261 Y250 F20000\n      M400 P200\n      G39 S1\n      G0 Z2 F4000\n    {endif}\n\n\n    M622.1 S1\n    M1002 judge_flag g39_detection_flag\n    M622 J1\n      {if !in_head_wrap_detect_zone}\n        M622.1 S0\n        M1002 judge_flag g39_mass_exceed_flag\n        M622 J1\n        {if layer_num > 2}\n            G392 S0\n            M400\n            G90\n            M83\n            M204 S5000\n            G0 Z{max_layer_z + 0.4} F4000\n            G39.3 S1\n            G0 Z{max_layer_z + 0.4} F4000\n            G392 S0\n          {endif}\n        M623\n    {endif}\n    M623\nM623\n; SKIPPABLE_END\n{endif}\n
; timelapse_type = 0
; top_area_threshold = 200%
; top_color_penetration_layers = 3
; top_one_wall_type = all top
; top_shell_layers = 3
; top_shell_thickness = 0.8
; top_solid_infill_flow_ratio = 1
; top_surface_acceleration = 2000
; top_surface_density = 100%
; top_surface_jerk = 9
; top_surface_line_width = 0.82
; top_surface_pattern = monotonic
; top_surface_speed = 150
; top_z_overrides_xy_distance = 0
; travel_acceleration = 10000
; travel_jerk = 9
; travel_short_distance_acceleration = 250
; travel_speed = 700
; travel_speed_z = 0
; tree_support_branch_angle = 45
; tree_support_branch_diameter = 2
; tree_support_branch_diameter_angle = 5
; tree_support_branch_distance = 5
; tree_support_wall_count = -1
; upward_compatible_machine = "Bambu Lab H2D 0.8 nozzle";"Bambu Lab H2D Pro 0.8 nozzle";"Bambu Lab H2S 0.8 nozzle";"Bambu Lab P2S 0.8 nozzle";"Bambu Lab H2C 0.8 nozzle";"Bambu Lab X2D 0.8 nozzle";"Bambu Lab A2L 0.8 nozzle"
; use_firmware_retraction = 0
; use_relative_e_distances = 1
; vertical_shell_speed = 80%
; volumetric_speed_coefficients = "0 0 0 0 0 0"
; wall_distribution_count = 1
; wall_filament = 0
; wall_generator = classic
; wall_loops = 3
; wall_sequence = inner wall/outer wall
; wall_transition_angle = 10
; wall_transition_filter_deviation = 25%
; wall_transition_length = 100%
; wipe = 1
; wipe_distance = 2
; wipe_speed = 80%
; wipe_tower_no_sparse_layers = 0
; wipe_tower_rotation_angle = 0
; wipe_tower_x = 15
; wipe_tower_y = 220
; wrapping_detection_gcode = 
; wrapping_detection_layers = 20
; wrapping_exclude_area = 
; xy_contour_compensation = 0
; xy_hole_compensation = 0
; z_direction_outwall_speed_continuous = 0
; z_hop = 0.4
; z_hop_types = Auto Lift
; CONFIG_BLOCK_END

; EXECUTABLE_BLOCK_START
M73 P0 R16
M201 X6000 Y6000 Z1500 E5000
M203 X500 Y500 Z30 E30
M204 P12000 R5000 T12000
M205 X9.00 Y9.00 Z3.00 E3.00
M106 S0
; FEATURE: Custom
;===== machine: A1 =========================
;===== date: 20260513 ==================
G392 S0
M9833.2
;M400
;M73 P1.717

;===== start to heat heatbead&hotend==========
M1002 gcode_claim_action : 2
M1002 set_filament_type:PLA
M104 S140
M140 S65

;=====start printer sound ===================
M17
M400 S1
M1006 S1
M1006 A0 B10 L100 C37 D10 M60 E37 F10 N60
M1006 A0 B10 L100 C41 D10 M60 E41 F10 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A43 B10 L100 C46 D10 M70 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C43 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C41 D10 M80 E41 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E44 F10 N80
M1006 A0 B10 L100 C49 D10 M80 E49 F10 N80
M1006 A0 B10 L100 C0 D10 M80 E0 F10 N80
M1006 A44 B10 L100 C48 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A43 B10 L100 C46 D10 M60 E39 F10 N80
M1006 W
M18 
;=====start printer sound ===================

;=====avoid end stop =================
G91
G380 S2 Z40 F1200
G380 S3 Z-15 F1200
G90

;===== reset machine status =================
;M290 X39 Y39 Z8
M204 S6000

M630 S0 P0
G91
M17 Z0.3 ; lower the z-motor current

G90
M17 X0.65 Y1.2 Z0.6 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
;M211 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem

;====== cog noise reduction=================
M982.2 S1 ; turn on cog noise reduction

M1002 gcode_claim_action : 13

G28 X
G91
G1 Z5 F1200
G90
G0 X128 F30000
G0 Y254 F3000
G91
G1 Z-5 F1200

M109 S25 H140

M17 E0.3
M83
G1 E10 F1200
G1 E-0.5 F30
M17 D

G28 Z P0 T140; home z with low precision,permit 300deg temperature
M104 S220

M1002 judge_flag build_plate_detect_flag
M622 S1
  G39.4
  G90
  G1 Z5 F1200
M623

;M400
;M73 P1.717

;===== prepare print temperature and material ==========
M1002 gcode_claim_action : 24

M400
;G392 S1
M211 X0 Y0 Z0 ;turn off soft endstop
M975 S1 ; turn on

G90
G1 X-28.5 F30000
G1 X-48.2 F3000

M620 M ;enable remap
M620 S0A   ; switch material if AMS exist
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S220

    M104 S220

    M400
    T0
    G1 X-48.2 F3000
    M400


    M620.1 E F523.843 T220
    M109 S220 ;set nozzle to common flush temp

    M106 P1 S0
    G92 E0
    G1 E50 F200
    M400
    M1002 set_filament_type:PLA
M621 S0A


    M109 S220 H300

G92 E0
G1 E50 F200 ; lower extrusion speed to avoid clog
M400
M106 P1 S178
G92 E0
G1 E5 F200
M104 S220
G92 E0
M73 P3 R16
G1 E-0.5 F300

G1 X-28.5 F30000
M73 P4 R15
G1 X-48.2 F3000
M73 P6 R15
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000

;G392 S0

M400
M106 P1 S0
;===== prepare print temperature and material end =====

;M400
;M73 P1.717

;===== auto extrude cali start =========================
M975 S1
;G392 S1

G90
M83
T1000
G1 X-48.2 Y0 Z10 F10000
M400
M1002 set_filament_type:UNKNOWN

M412 S1 ;  ===turn on  filament runout detection===
M400 P10
M620.3 W1; === turn on filament tangle detection===
M400 S2

M1002 set_filament_type:PLA

;M1002 set_flag extrude_cali_flag=1
M1002 judge_flag extrude_cali_flag

M622 J1
    M1002 gcode_claim_action : 8

    M109 S220
    G1 E10 F525
    M983 F8.75 A0.3 H0.8; cali dynamic extrusion compensation

    M106 P1 S255
    M400 S5
    G1 X-28.5 F18000
    G1 X-48.2 F3000
    G1 X-28.5 F18000 ;wipe and shake
    G1 X-48.2 F3000
M73 P8 R15
    G1 X-28.5 F12000 ;wipe and shake
    G1 X-48.2 F3000
    M400
    M106 P1 S0

    M1002 judge_last_extrude_cali_success
    M622 J0
        M983 F8.75 A0.3 H0.8; cali dynamic extrusion compensation
        M106 P1 S255
        M400 S5
        G1 X-28.5 F18000
        G1 X-48.2 F3000
        G1 X-28.5 F18000 ;wipe and shake
        G1 X-48.2 F3000
        G1 X-28.5 F12000 ;wipe and shake
        M400
        M106 P1 S0
    M623
    
M73 P9 R15
    G1 X-48.2 F3000
    M400
    M984 A0.1 E1 S1 F8.75 H0.8
    M106 P1 S178
    M400 S7
    G1 X-28.5 F18000
    G1 X-48.2 F3000
    G1 X-28.5 F18000 ;wipe and shake
    G1 X-48.2 F3000
    G1 X-28.5 F12000 ;wipe and shake
    G1 X-48.2 F3000
    M400
    M106 P1 S0
M623 ; end of "draw extrinsic para cali paint"

;G392 S0
;===== auto extrude cali end ========================

;M400
;M73 P1.717

M104 S170 ; prepare to wipe nozzle
M106 S255 ; turn on fan

;===== mech mode fast check start =====================
M1002 gcode_claim_action : 3

G1 X128 Y128 F20000
G1 Z5 F1200
M400 P200
M970.3 Q1 A5 K0 O3
M974 Q1 S2 P0

M970.2 Q1 K1 W58 Z0.1
M974 S2

G1 X128 Y128 F20000
G1 Z5 F1200
M400 P200
M970.3 Q0 A10 K0 O1
M974 Q0 S2 P0

M970.2 Q0 K1 W78 Z0.1
M974 S2

M975 S1
G1 F30000
G1 X0 Y5
G28 X ; re-home XY

G1 Z4 F1200

;===== mech mode fast check end =======================

;M400
;M73 P1.717

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14

M975 S1
M106 S255 ; turn on fan (G28 has turn off fan)
M211 S; push soft endstop status
M211 X0 Y0 Z0 ;turn off Z axis endstop

;===== remove waste by touching start =====

M104 S170 ; set temp down to heatbed acceptable

M83
G1 E-1 F500
G90
M83

M109 S170
G0 X108 Y-0.5 F30000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X110 F10000
G380 S3 Z-5 F1200
M73 P35 R10
G1 Z2 F1200
G1 X112 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X114 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X116 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X118 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X120 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X122 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X124 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X126 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X128 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X130 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X132 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X134 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X136 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X138 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X140 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X142 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X144 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X146 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X148 F10000
G380 S3 Z-5 F1200

G1 Z5 F30000
;===== remove waste by touching end =====

G1 Z10 F1200
G0 X118 Y261 F30000
G1 Z5 F1200
M109 S170

G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
M104 S140 ; prepare to abl
G0 Z5 F20000

G0 X128 Y261 F20000  ; move to exposed steel surface
G0 Z-1.01 F1200      ; stop the nozzle

G91
G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

G90
G1 Z10 F1200

;===== brush material wipe nozzle =====

G90
G1 Y250 F30000
G1 X55
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X-35 F30000
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
M73 P36 R10
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

G90
G1 X30 Y250.000 F30000
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X35 F30000
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Z10.000 F1200

;===== brush material wipe nozzle end =====

G90
;G0 X128 Y261 F20000  ; move to exposed steel surface
G1 Y250 F30000
G1 X138
G1 Y261
G0 Z-1.01 F1200      ; stop the nozzle

G91
G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

M109 S140
M106 S255 ; turn on fan (G28 has turn off fan)

M211 R; pop softend status

;===== wipe nozzle end ================================

;M400
;M73 P1.717

;===== bed leveling ==================================
M1002 judge_flag g29_before_print_flag

G90
G1 Z5 F1200
G1 X0 Y0 F30000
G29.2 S1 ; turn on ABL

M190 S65; ensure bed temp
M109 S140
M106 S0 ; turn off fan , too noisy

M622 J1
    M1002 gcode_claim_action : 1
    G29 A1 X106.81 Y117 I42.38 J21.9992
    M400
    M500 ; save cali data
M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623

;===== home after wipe mouth end =======================

;M400
;M73 P1.717

G1 X108.000 Y-0.500 F30000
G1 Z0.300 F1200
M400
G2814 Z0.32

M104 S220 ; prepare to print

;===== nozzle load line ===============================
;G90
;M83
;G1 Z5 F1200
;G1 X88 Y-0.5 F20000
;G1 Z0.3 F1200

;M109 S220

;G1 E2 F300
;G1 X168 E4.989 F6000
;G1 Z1 F1200
;===== nozzle load line end ===========================

;===== extrude cali test ===============================

M400
    M900 S
    M900 C
    G90
    M83

    M109 S220
    G0 X128 E8  F1260
    G0 X133 E.3742  F2100
    G0 X138 E.3742  F8400
    G0 X143 E.3742  F2100
    G0 X148 E.3742  F8400
    G0 X153 E.3742  F2100
    G91
    G1 X1 Z-0.300
    G1 X4
    G1 Z1 F1200
    G90
    M400

M900 R

M1002 judge_flag extrude_cali_flag
M622 J1
    G90
    G1 X108.000 Y1.000 F30000
    G91
    G1 Z-0.700 F1200
    G90
    M83
    G0 X128 E10  F1260
    G0 X133 E.3742  F2100
    G0 X138 E.3742  F8400
    G0 X143 E.3742  F2100
    G0 X148 E.3742  F8400
    G0 X153 E.3742  F2100
    G91
    G1 X1 Z-0.300
    G1 X4
    G1 Z1 F1200
    G90
    M400
M623

G1 Z0.2

;M400
;M73 P1.717

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M400

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type=Textured PEI Plate

G29.1 Z-0.02 ; for Textured PEI Plate


M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
;G392 S1 ; turn on clog detection
M1007 S1 ; turn on mass estimation
G29.4
; MACHINE_START_GCODE_END
; filament start gcode
M106 P3 S200


;VT0 H-1
G90
G21
M83 ; use relative distances for extrusion
M981 S1 P20000 ;open spaghetti detector
; CHANGE_LAYER
; Z_HEIGHT: 0.4
; LAYER_HEIGHT: 0.4
G1 E-.8 F1800
; layer num/total_layer_count: 1/51
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change
M106 S0
; OBJECT_ID: 15
G1 X147.237 Y120.903 F42000
M204 S6000
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F2100
M204 S500
G1 X147.237 Y135.097 E1.69824
G1 X123.481 Y135.097 E2.84241
G1 X122.496 Y135.734 E.14035
G3 X118.147 Y118.965 I-4.689 J-7.733 E4.02983
M73 P37 R10
G3 X122.496 Y120.266 I-.352 J9.095 E.5489
G1 X123.481 Y120.903 E.14035
G1 X147.117 Y120.903 E2.82805
; WIPE_START
G1 X147.134 Y122.903 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X147.971 Y120.169 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F2100
M204 S500
G1 X147.971 Y135.831 E1.87392
G1 X123.698 Y135.831 E2.90429
G3 X120.198 Y137.483 I-6.324 J-8.864 E.46557
G3 X118.176 Y118.231 I-2.392 J-9.481 E4.00891
G3 X122.877 Y119.637 I-.381 J9.833 E.59336
G1 X123.698 Y120.169 E.11704
G1 X147.851 Y120.169 E2.88993
; WIPE_START
G1 X147.866 Y122.169 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X148.705 Y119.435 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
G1 F2100
M204 S500
G1 X148.705 Y136.565 E2.0496
G1 X123.915 Y136.565 E2.96616
G3 X118.204 Y117.497 I-6.105 J-8.56 E4.77887
G3 X123.915 Y119.435 I-.402 J10.57 E.73171
G1 X148.585 Y119.435 E2.9518
; WIPE_START
G1 X148.599 Y121.435 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G17
G3 Z.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z0.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X146.943 Y122.703 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.830471
G1 F3300
M204 S500
G1 X145.767 Y121.527 E.20181
G1 X144.714 Y121.527 E.12779
G1 X146.613 Y123.426 E.32584
G1 X146.613 Y124.479 E.12779
G1 X143.661 Y121.527 E.50657
G1 X142.608 Y121.527 E.12779
G1 X146.613 Y125.532 E.6873
G1 X146.613 Y126.585 E.1278
G1 X141.555 Y121.527 E.86803
G1 X140.502 Y121.527 E.1278
G1 X146.613 Y127.638 E1.04876
M73 P38 R10
G1 X146.613 Y128.691 E.1278
G1 X139.449 Y121.527 E1.22949
G1 X138.396 Y121.527 E.1278
G1 X146.613 Y129.744 E1.41022
G1 X146.613 Y130.797 E.1278
G1 X137.343 Y121.527 E1.59095
G1 X136.29 Y121.527 E.1278
G1 X146.613 Y131.85 E1.77168
G1 X146.613 Y132.903 E.1278
G1 X135.237 Y121.527 E1.95241
G1 X134.183 Y121.527 E.12779
G1 X146.613 Y133.957 E2.13314
G1 X146.613 Y134.473 E.06264
G1 X146.076 Y134.473 E.06515
G1 X133.13 Y121.527 E2.22173
G1 X132.077 Y121.527 E.12779
G1 X145.023 Y134.473 E2.22173
G1 X143.97 Y134.473 E.1278
G1 X131.024 Y121.527 E2.22173
G1 X129.971 Y121.527 E.12779
G1 X142.917 Y134.473 E2.22173
G1 X141.864 Y134.473 E.12779
G1 X128.918 Y121.527 E2.22173
G1 X127.865 Y121.527 E.1278
G1 X140.811 Y134.473 E2.22173
G1 X139.757 Y134.473 E.12779
G1 X126.812 Y121.527 E2.22173
G1 X125.759 Y121.527 E.1278
G1 X138.704 Y134.473 E2.22173
G1 X137.651 Y134.473 E.1278
G1 X124.706 Y121.527 E2.22173
G1 X123.653 Y121.527 E.1278
G1 X136.598 Y134.473 E2.22173
G1 X135.545 Y134.473 E.1278
G1 X121.517 Y120.445 E2.40749
G2 X119.85 Y119.831 I-3.85 J7.885 E.21594
G1 X134.492 Y134.473 E2.51284
G1 X133.439 Y134.473 E.1278
G1 X118.592 Y119.625 E2.54816
G2 X117.503 Y119.59 I-.768 J6.801 E.13233
G1 X132.386 Y134.473 E2.55428
G1 X131.333 Y134.473 E.1278
G1 X116.538 Y119.678 E2.53911
G2 X115.666 Y119.859 I1.272 J8.343 E.10817
M73 P39 R10
G1 X130.28 Y134.473 E2.50812
G1 X129.227 Y134.473 E.12779
G1 X114.865 Y120.11 E2.46489
G2 X114.128 Y120.427 I2.326 J6.43 E.09735
G1 X128.174 Y134.473 E2.41058
G1 X127.121 Y134.473 E.12779
G1 X113.446 Y120.798 E2.3469
G2 X112.815 Y121.22 I3.163 J5.414 E.09219
G1 X126.068 Y134.473 E2.27449
G1 X125.015 Y134.473 E.1278
G1 X112.232 Y121.69 E2.19376
G2 X111.696 Y122.207 I4.059 J4.745 E.09043
G1 X123.961 Y134.473 E2.10504
G1 X123.296 Y134.473 E.08075
G1 X123.061 Y134.625 E.03402
G1 X111.207 Y122.771 E2.03439
G2 X110.765 Y123.383 I4.898 J4.002 E.09159
G1 X122.422 Y135.039 E2.00049
G3 X121.762 Y135.432 I-3.58 J-5.254 E.09327
G1 X110.374 Y124.045 E1.95443
G2 X110.034 Y124.758 I5.892 J3.242 E.09595
G1 X121.046 Y135.769 E1.88976
G3 X120.273 Y136.05 I-3.623 J-8.768 E.09977
G1 X109.757 Y125.533 E1.80485
G2 X109.545 Y126.374 I8.516 J2.595 E.1053
G1 X119.431 Y136.261 E1.69677
G3 X118.507 Y136.389 I-1.782 J-9.434 E.11333
G1 X109.414 Y127.297 E1.56046
G2 X109.392 Y128.328 I9.79 J.728 E.12516
G1 X117.477 Y136.413 E1.38758
G3 X116.294 Y136.283 I.081 J-6.186 E.14467
G1 X109.524 Y129.513 E1.16177
G2 X109.929 Y130.971 I7.025 J-1.164 E.18391
G1 X114.836 Y135.878 E.84222
G3 X112.047 Y134.142 I3.003 J-7.934 E.40128
G1 X110.153 Y132.248 E.32495
; CHANGE_LAYER
; Z_HEIGHT: 0.96
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3300
G1 X111.568 Y133.663 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 2/51
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change
M106 S191.25
; open powerlost recovery
M1003 S1
; OBJECT_ID: 15
M204 S10000
G17
G3 Z.96 I.578 J1.603 P1  F42000
G1 X147.38 Y120.76 Z.96
M73 P40 R10
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.523 Y135.24 E3.80943
G3 X121.603 Y136.368 I-7.513 J-10.593 E.35603
G3 X118.399 Y118.83 I-3.795 J-8.368 E5.32816
G3 X122.573 Y120.144 I-.607 J9.218 E.70551
G1 X123.523 Y120.76 E.1807
G1 X147.26 Y120.76 E3.79027
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z1.36 F42000
M73 P40 R9
G1 Z.96
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88814
G3 X120.227 Y137.589 I-6.32 J-8.884 E.62149
G3 X118.445 Y118.132 I-2.419 J-9.588 E5.45271
G3 X122.935 Y119.545 I-.655 J9.921 E.75883
G1 X123.73 Y120.06 E.15114
G1 X147.96 Y120.06 E3.86898
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z1.36 F42000
G1 Z.96
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96685
G3 X118.492 Y117.433 I-6.127 J-8.638 E6.46466
G3 X123.937 Y119.36 I-.736 J10.737 E.93365
G1 X148.66 Y119.36 E3.94768
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.36 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.36
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X145.671 Y134.96 F42000
G1 Z.96
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.826887
G1 F3183.767
M204 S6000
G1 X146.786 Y133.846 E.25411
G1 X146.786 Y132.847 E.16116
G1 X144.987 Y134.646 E.41021
G1 X143.987 Y134.646 E.16115
G1 X146.786 Y131.847 E.63811
G1 X146.786 Y130.848 E.16116
G1 X142.988 Y134.646 E.86602
G1 X141.988 Y134.646 E.16116
G1 X146.786 Y129.848 E1.09393
G1 X146.786 Y128.849 E.16116
G1 X140.989 Y134.646 E1.32184
G1 X139.99 Y134.646 E.16116
G1 X146.786 Y127.85 E1.54974
G1 X146.786 Y126.85 E.16116
M73 P41 R9
G1 X138.99 Y134.646 E1.77765
G1 X137.991 Y134.646 E.16116
G1 X146.786 Y125.851 E2.00556
G1 X146.786 Y124.851 E.16116
G1 X136.991 Y134.646 E2.23347
G1 X135.992 Y134.646 E.16115
G1 X146.786 Y123.852 E2.46138
G1 X146.786 Y122.852 E.16116
G1 X134.992 Y134.646 E2.68929
G1 X133.993 Y134.646 E.16116
G1 X146.786 Y121.853 E2.9172
G1 X146.786 Y121.354 E.08037
G1 X146.285 Y121.354 E.08078
G1 X132.993 Y134.646 E3.03086
G1 X131.994 Y134.646 E.16116
G1 X145.285 Y121.354 E3.03086
G1 X144.286 Y121.354 E.16116
G1 X130.995 Y134.646 E3.03086
G1 X129.995 Y134.646 E.16116
G1 X143.286 Y121.354 E3.03086
G1 X142.287 Y121.354 E.16116
G1 X128.996 Y134.646 E3.03086
G1 X127.996 Y134.646 E.16116
G1 X141.287 Y121.354 E3.03086
G1 X140.288 Y121.354 E.16116
G1 X126.997 Y134.646 E3.03086
G1 X125.997 Y134.646 E.16116
G1 X139.288 Y121.354 E3.03086
G1 X138.289 Y121.354 E.16116
G1 X124.998 Y134.646 E3.03086
G1 X123.998 Y134.646 E.16116
G1 X137.29 Y121.354 E3.03086
G1 X136.29 Y121.354 E.16116
G1 X122.359 Y135.286 E3.17687
G3 X120.48 Y136.165 I-4.636 J-7.457 E.33533
G1 X135.291 Y121.354 E3.37746
G1 X134.291 Y121.354 E.16116
G1 X119.163 Y136.483 E3.44979
G3 X118.059 Y136.587 I-1.369 J-8.573 E.17893
G1 X133.292 Y121.354 E3.47363
G1 X132.292 Y121.354 E.16116
G1 X117.087 Y136.56 E3.46731
G3 X116.206 Y136.441 I.688 J-8.464 E.14342
G1 X131.293 Y121.354 E3.44034
G1 X130.294 Y121.354 E.16116
G1 X115.399 Y136.249 E3.39657
G3 X114.657 Y135.992 I2.922 J-9.62 E.12668
G1 X129.294 Y121.354 E3.33787
G1 X128.295 Y121.354 E.16116
G1 X113.963 Y135.686 E3.26822
G3 X113.322 Y135.328 I5.154 J-9.974 E.11845
G1 X127.295 Y121.354 E3.18651
G1 X126.296 Y121.354 E.16116
G1 X112.724 Y134.926 E3.09488
G3 X112.167 Y134.484 I5.708 J-7.758 E.11473
G1 X125.296 Y121.354 E2.99399
G1 X124.297 Y121.354 E.16116
G1 X111.654 Y133.997 E2.88299
G3 X111.181 Y133.471 I3.95 J-4.032 E.11419
G1 X123.317 Y121.335 E2.76749
G1 X122.71 Y120.942 E.11653
M73 P42 R9
G1 X110.75 Y132.902 E2.72742
G3 X110.362 Y132.291 I4.935 J-3.56 E.11684
G1 X122.095 Y120.558 E2.67558
G2 X121.439 Y120.214 I-3.349 J5.592 E.11945
G1 X110.019 Y131.634 E2.6042
G3 X109.728 Y130.926 I5.799 J-2.801 E.12353
G1 X120.732 Y119.923 E2.50924
G2 X119.97 Y119.684 I-2.378 J6.265 E.1287
G1 X109.491 Y130.164 E2.38966
G3 X109.317 Y129.338 I7.227 J-1.952 E.13612
G1 X119.141 Y119.514 E2.24027
G2 X118.236 Y119.42 I-1.463 J9.642 E.14678
G1 X109.225 Y128.431 E2.05492
G3 X109.234 Y127.423 I8.765 J-.428 E.16266
G1 X117.228 Y119.428 E1.8231
G2 X116.071 Y119.586 I.675 J9.258 E.18852
G1 X109.388 Y126.269 E1.52386
G3 X109.814 Y124.844 I7.83 J1.562 E.24014
G1 X114.645 Y120.013 E1.1016
G2 X111.9 Y121.758 I3.167 J8.011 E.5275
G1 X110.064 Y123.594 E.41879
; CHANGE_LAYER
; Z_HEIGHT: 1.52
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3183.767
G1 X111.478 Y122.18 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 3/51
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z1.52 I.067 J1.702 P1  F42000
G1 X147.38 Y120.76 Z1.52
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.523 Y135.24 E3.80945
G3 X121.604 Y136.367 I-7.42 J-10.435 E.35575
G3 X118.418 Y118.831 I-3.796 J-8.368 E5.33158
G3 X122.572 Y120.144 I-.616 J9.182 E.70237
G1 X123.523 Y120.76 E.18083
G1 X147.26 Y120.76 E3.79029
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z1.92 F42000
G1 Z1.52
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88815
G3 X120.226 Y137.589 I-6.318 J-8.879 E.62153
G3 X118.446 Y118.132 I-2.418 J-9.589 E5.45237
G3 X122.936 Y119.545 I-.654 J9.916 E.75877
G1 X123.73 Y120.06 E.15112
G1 X147.96 Y120.06 E3.86899
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z1.92 F42000
G1 Z1.52
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96685
G3 X107.581 Y125.247 I-6.125 J-8.644 E4.14382
G3 X118.474 Y117.433 I10.223 J2.75 E2.31807
G3 X123.937 Y119.36 I-.715 J10.732 E.93651
G1 X148.66 Y119.36 E3.94769
; WIPE_START
M204 S6000
M73 P43 R9
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.92 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.92
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    
      M400
      G90
      M83
      M204 S5000
      G0 Z2 F4000
      G0 X261 Y250 F20000
      M400 P200
      G39 S1
      G0 Z2 F4000
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


G1 Z1.920
G1 X147.1 Y122.469 F42000
G1 Z1.52
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.826887
G1 F3183.767
M204 S6000
G1 X145.986 Y121.354 E.25411
G1 X144.987 Y121.354 E.16115
G1 X146.786 Y123.153 E.4102
G1 X146.786 Y124.153 E.16116
G1 X143.987 Y121.354 E.63811
G1 X142.988 Y121.354 E.16116
G1 X146.786 Y125.152 E.86602
G1 X146.786 Y126.152 E.16116
G1 X141.988 Y121.354 E1.09393
G1 X140.989 Y121.354 E.16116
G1 X146.786 Y127.151 E1.32184
G1 X146.786 Y128.15 E.16116
G1 X139.99 Y121.354 E1.54975
G1 X138.99 Y121.354 E.16116
G1 X146.786 Y129.15 E1.77766
G1 X146.786 Y130.149 E.16116
G1 X137.991 Y121.354 E2.00556
G1 X136.991 Y121.354 E.16115
G1 X146.786 Y131.149 E2.23347
G1 X146.786 Y132.148 E.16116
G1 X135.992 Y121.354 E2.46138
G1 X134.992 Y121.354 E.16116
G1 X146.786 Y133.148 E2.68929
G1 X146.786 Y134.147 E.16116
G1 X133.993 Y121.354 E2.9172
G1 X132.993 Y121.354 E.16116
G1 X146.285 Y134.646 E3.03086
G1 X145.285 Y134.646 E.16115
G1 X131.994 Y121.354 E3.03086
G1 X130.995 Y121.354 E.16116
G1 X144.286 Y134.646 E3.03086
G1 X143.286 Y134.646 E.16116
G1 X129.995 Y121.354 E3.03086
G1 X128.996 Y121.354 E.16116
G1 X142.287 Y134.646 E3.03086
G1 X141.287 Y134.646 E.16116
G1 X127.996 Y121.354 E3.03086
G1 X126.997 Y121.354 E.16116
G1 X140.288 Y134.646 E3.03086
G1 X139.288 Y134.646 E.16116
G1 X125.997 Y121.354 E3.03086
G1 X124.998 Y121.354 E.16116
G1 X138.289 Y134.646 E3.03086
G1 X137.29 Y134.646 E.16116
G1 X123.998 Y121.354 E3.03086
G1 X123.347 Y121.354 E.10506
G1 X122.359 Y120.714 E.18991
M73 P44 R9
G1 X136.29 Y134.646 E3.17691
G1 X135.291 Y134.646 E.16116
G1 X120.48 Y119.834 E3.37747
G2 X119.163 Y119.517 I-2.303 J6.669 E.21869
G1 X134.291 Y134.646 E3.44978
G1 X133.292 Y134.646 E.16116
G1 X118.059 Y119.413 E3.47365
G2 X117.086 Y119.439 I-.245 J8.768 E.15697
G1 X132.292 Y134.646 E3.46754
G1 X131.293 Y134.646 E.16116
G1 X116.206 Y119.559 E3.44035
G2 X115.399 Y119.751 I1.215 J6.904 E.13391
G1 X130.294 Y134.646 E3.39659
G1 X129.294 Y134.646 E.16116
G1 X114.656 Y120.007 E3.33803
G2 X113.963 Y120.314 I2.21 J5.945 E.12228
G1 X128.295 Y134.646 E3.26823
G1 X127.295 Y134.646 E.16115
G1 X113.322 Y120.672 E3.18651
G2 X112.723 Y121.073 I3.061 J5.22 E.11623
G1 X126.296 Y134.646 E3.09512
G1 X125.296 Y134.646 E.16116
G1 X112.167 Y121.516 E2.99398
G2 X111.654 Y122.003 I3.826 J4.544 E.11406
G1 X124.297 Y134.646 E2.88299
G1 X123.347 Y134.646 E.15317
G1 X123.317 Y134.665 E.00577
G1 X111.18 Y122.528 E2.76764
G2 X110.75 Y123.098 I8.146 J6.599 E.11508
G1 X122.71 Y135.058 E2.72741
G3 X122.096 Y135.443 I-3.542 J-4.977 E.117
G1 X110.362 Y123.709 E2.67571
G2 X110.019 Y124.366 I9.531 J5.393 E.11947
G1 X121.439 Y135.786 E2.60421
G3 X120.731 Y136.077 I-4.131 J-9.025 E.12348
G1 X109.728 Y125.074 E2.50924
G2 X109.49 Y125.836 I8.87 J3.181 E.12874
G1 X119.97 Y136.316 E2.38978
G3 X119.141 Y136.486 I-2.508 J-10.087 E.13649
G1 X109.317 Y126.662 E2.24029
G2 X109.225 Y127.569 I9.894 J1.464 E.14709
G1 X118.236 Y136.58 E2.0549
G3 X117.228 Y136.572 I-.428 J-8.936 E.16264
G1 X109.234 Y128.577 E1.82304
G2 X109.388 Y129.731 I9.118 J-.634 E.18787
G1 X116.071 Y136.414 E1.52386
G3 X114.646 Y135.989 I1.294 J-6.936 E.24013
G1 X109.814 Y131.156 E1.102
G2 X111.608 Y133.95 I7.857 J-3.073 E.53882
G1 X113.399 Y135.741 E.4086
; CHANGE_LAYER
; Z_HEIGHT: 2.08
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3183.767
M73 P45 R9
G1 X111.985 Y134.327 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 4/51
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change
M106 S198.9
; OBJECT_ID: 15
M204 S10000
G17
G3 Z2.08 I.61 J1.591 P1  F42000
G1 X147.38 Y120.76 Z2.08
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.523 Y135.24 E3.80946
G3 X121.606 Y136.367 I-7.531 J-10.622 E.35543
G3 X118.387 Y118.83 I-3.798 J-8.367 E5.32684
G3 X122.574 Y120.145 I-.597 J9.227 E.70749
G1 X123.523 Y120.76 E.18055
G1 X147.26 Y120.76 E3.7903
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z2.48 F42000
G1 Z2.08
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88816
G3 X120.228 Y137.588 I-6.318 J-8.88 E.62128
G3 X118.416 Y118.131 I-2.42 J-9.588 E5.44779
G3 X122.937 Y119.546 I-.635 J9.956 E.76374
G1 X123.73 Y120.06 E.15081
G1 X147.96 Y120.06 E3.86899
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z2.48 F42000
G1 Z2.08
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96685
G3 X118.445 Y117.432 I-6.127 J-8.638 E6.45713
G3 X123.937 Y119.36 I-.682 J10.724 E.94108
G1 X148.66 Y119.36 E3.94769
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.48 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.48
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.48 F4000
            G39.3 S1
            G0 Z2.48 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X146.786 Y131.78 F42000
G1 Z2.08
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G1 X146.786 Y133.147 E.21829
G1 X146.086 Y132.447 E.15805
G1 X146.086 Y132.89 E.07064
G1 X135.25 Y122.054 E2.44676
G1 X133.946 Y122.054 E.20833
G1 X119.6 Y136.4 E3.23942
G2 X122.192 Y135.388 I-2.147 J-9.326 E.44586
G1 X110.418 Y123.614 E2.65867
G2 X110.418 Y132.386 I7.386 J4.386 E1.46989
G1 X122.192 Y120.612 E2.65868
G2 X119.598 Y119.598 I-4.767 J8.374 E.44621
G1 X133.946 Y133.946 E3.23981
G1 X135.25 Y133.946 E.20834
G1 X146.786 Y122.41 E2.6048
G1 X146.786 Y121.354 E.16861
G1 X145.042 Y121.354 E.27836
M204 S10000
G1 X133.13 Y134.593 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.800486
M73 P46 R9
G1 F3307.322
M204 S6000
G1 X146.435 Y134.593 E2.06526
G1 X146.682 Y134.542 E.03907
G2 X146.733 Y134.13 I-.969 J-.329 E.06487
M204 S10000
G1 X124.152 Y121.407 F42000
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X136.414 Y121.407 E1.90255
; CHANGE_LAYER
; Z_HEIGHT: 2.64
; LAYER_HEIGHT: 0.56
; WIPE_START
M73 P46 R8
G1 F3308.823
G1 X134.414 Y121.407 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 5/51
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change
M106 S193.8
; OBJECT_ID: 15
M204 S10000
G17
G3 Z2.64 I.085 J1.702 P1  F42000
G1 X147.38 Y120.76 Z2.64
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.523 Y135.24 E3.80947
G3 X121.607 Y136.366 I-7.66 J-10.841 E.35515
G3 X118.357 Y118.829 I-3.8 J-8.366 E5.32221
G3 X122.575 Y120.146 I-.578 J9.267 E.71254
G1 X123.523 Y120.76 E.18025
G1 X147.26 Y120.76 E3.79032
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88817
G3 X120.229 Y137.588 I-6.318 J-8.88 E.62106
G3 X118.386 Y118.13 I-2.423 J-9.587 E5.44375
G3 X122.939 Y119.547 I-.613 J9.989 E.76879
G1 X123.73 Y120.06 E.15052
G1 X147.96 Y120.06 E3.869
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96685
G3 X118.415 Y117.43 I-6.127 J-8.637 E6.45229
G3 X123.937 Y119.36 I-.647 J10.717 E.94591
G1 X148.66 Y119.36 E3.94769
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.04 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.04
M106 S255
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.04 F4000
            G39.3 S1
            G0 Z3.04 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X142.619 Y126.577 F42000
G1 Z2.64
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G1 X146.786 Y122.41 E.94082
M204 S10000
G1 X126.834 Y128.095 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.83037
; LAYER_HEIGHT: 0.8
G1 F1800
M204 S6000
G1 X133.31 Y134.57 E2.02074
G1 X134.555 Y134.57 E.27471
G1 X127.727 Y127.742 E2.13059
G1 X128.35 Y127.12 E.19425
G1 X135.8 Y134.57 E2.32484
M73 P47 R8
G1 X137.045 Y134.57 E.27471
G1 X128.972 Y126.497 E2.51909
G1 X129.197 Y126.272 E.07031
G1 X124.355 Y121.43 E1.51107
G1 X125.149 Y121.43 E.17527
G1 X138.29 Y134.57 E4.10048
G1 X139.535 Y134.57 E.27471
G1 X126.394 Y121.43 E4.10048
G1 X127.639 Y121.43 E.27471
G1 X140.78 Y134.57 E4.10048
G1 X142.025 Y134.57 E.27471
G1 X128.884 Y121.43 E4.10048
G1 X130.129 Y121.43 E.27471
G1 X143.27 Y134.57 E4.10048
G1 X144.515 Y134.57 E.27471
G1 X131.374 Y121.43 E4.10047
G1 X132.619 Y121.43 E.27471
G1 X145.76 Y134.57 E4.10047
G1 X146.71 Y134.57 E.20965
G1 X146.71 Y134.276 E.06506
G1 X133.864 Y121.43 E4.00846
G1 X135.109 Y121.43 E.27471
G1 X141.703 Y128.023 E2.0575
G1 X142.326 Y127.401 E.19425
G1 X135.972 Y121.047 E1.98261
M106 S193.8
M204 S10000
G1 X112.208 Y134.521 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
; LAYER_HEIGHT: 0.56
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.45 J-7.224 E.4465
G1 X122.192 Y120.612 E2.65867
G2 X119.598 Y119.598 I-4.766 J8.371 E.44621
G1 X127.187 Y127.187 E1.71357
G1 X125.998 Y128.376 E.2685
G1 X126.811 Y129.189 E.18364
G1 X119.601 Y136.399 E1.62802
G2 X122.192 Y135.388 I-2.128 J-9.28 E.44561
G1 X110.418 Y123.614 E2.65867
G3 X112.208 Y121.479 I8.245 J5.093 E.44652
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.107 Y122.617 E-.60194
G1 X110.871 Y122.96 E-.15806
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 6/51
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change
M106 S196.35
; OBJECT_ID: 15
M204 S10000
G17
G3 Z3.2 I.102 J1.701 P1  F42000
G1 X147.38 Y120.76 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
M73 P48 R8
G1 X123.523 Y135.24 E3.80949
G3 X121.609 Y136.365 I-7.768 J-11.024 E.35488
G3 X118.329 Y118.828 I-3.801 J-8.365 E5.31798
G3 X122.577 Y120.146 I-.512 J9.15 E.71742
G1 X123.523 Y120.76 E.17998
G1 X147.26 Y120.76 E3.79032
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88817
G3 X120.231 Y137.588 I-6.318 J-8.88 E.62082
G3 X118.358 Y118.128 I-2.424 J-9.586 E5.43946
G3 X122.94 Y119.548 I-.539 J9.847 E.77374
G1 X123.73 Y120.06 E.15024
G1 X147.96 Y120.06 E3.86901
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96686
G3 X107.419 Y130.049 I-6.125 J-8.643 E3.37013
G3 X107.249 Y127.201 I10.538 J-2.058 E.45682
G3 X118.387 Y117.429 I10.56 J.802 E2.62039
G3 X123.937 Y119.36 I-.616 J10.712 E.95036
G1 X148.66 Y119.36 E3.9477
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.6 F4000
            G39.3 S1
            G0 Z3.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X145.042 Y121.354 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G1 X146.786 Y121.354 E.27836
G1 X146.786 Y122.41 E.16861
G1 X142.435 Y126.761 E.98252
G3 X142.434 Y129.238 I-5.846 J1.238 E.39841
G1 X146.786 Y133.59 E.98254
G1 X146.786 Y134.646 E.16861
G1 X145.042 Y134.646 E.27836
M204 S10000
G1 X138.705 Y128.856 F42000
; FEATURE: Top surface
; LINE_WIDTH: 0.840717
G1 F3122.658
M204 S2000
G1 X136.397 Y131.164 E.53664
M204 S10000
G1 X135.242 Y132.319 F42000
G1 F3122.658
M204 S2000
G1 X134.197 Y133.364 E.2431
G3 X133.213 Y133.329 I-.381 J-3.101 E.16251
G1 X138.452 Y128.09 E1.21818
G1 X138.442 Y127.558 E.08739
G1 X138.382 Y127.141 E.06927
M73 P49 R8
G1 X132.479 Y133.044 E1.3725
G1 X132.445 Y133.024 E.00638
G3 X131.972 Y132.651 I4.76 J-6.511 E.0991
G1 X131.972 Y132.532 E.0196
G1 X138.184 Y126.321 E1.44406
G1 X138.073 Y126.031 E.05095
G1 X137.817 Y126.283 E.05898
G1 X137.479 Y126.006 E.07184
G1 X131.548 Y131.937 E1.37911
G1 X131.183 Y131.582 E.08377
G1 X131.159 Y131.541 E.0078
G3 X131.083 Y131.383 I2.096 J-1.11 E.02879
G1 X136.914 Y125.552 E1.35571
G1 X136.302 Y125.146 E.12086
G1 X130.843 Y130.604 E1.26912
G3 X130.807 Y130.278 I2.566 J-.447 E.05389
G1 X130.807 Y129.621 E.1081
G1 X135.65 Y124.778 E1.12606
G1 X134.967 Y124.442 E.12519
G1 X131.079 Y128.33 E.90379
G1 X131.162 Y128.224 E.02202
G1 X131.161 Y127.779 E.07314
G1 X130.919 Y127.471 E.06441
G1 X135.44 Y122.95 E1.05127
G2 X134.647 Y122.724 I-1.163 J2.581 E.13607
G1 X130.807 Y126.564 E.89279
G3 X130.815 Y125.592 I7.762 J-.421 E.15989
G1 X130.823 Y125.529 E.01046
G1 X133.738 Y122.614 E.6778
G2 X132.342 Y123.047 I-.011 J2.433 E.24418
G2 X132.049 Y123.284 I3.087 J4.102 E.06198
G1 X130.754 Y124.579 E.301
M204 S10000
G1 X129.993 Y125.802 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.18458
G1 F2113.867
M204 S6000
G1 X129.86 Y125.802 E.03231
G1 X129.794 Y125.918 E.03231
G1 X129.86 Y126.033 E.03231
G1 X130 Y126.021 E.03401
M204 S10000
G1 X129.992 Y129.987 F42000
; LINE_WIDTH: 1.18642
G1 F2110.219
M204 S6000
G1 X129.859 Y129.987 E.03242
G1 X129.792 Y130.103 E.03242
G1 X129.859 Y130.218 E.03242
G1 X129.999 Y130.207 E.03415
M204 S10000
G1 X133.207 Y122.034 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X133.4 Y122.014 E.02996
M204 S10000
G1 X133.207 Y122.034 F42000
; LINE_WIDTH: 0.763665
G1 F3496.567
M204 S6000
G3 X132.012 Y121.473 I2.331 J-6.52 E.19413
G1 X131.941 Y121.514 E.01201
G1 X131.941 Y122.523 E.14812
G3 X132.658 Y122.126 I2.425 J3.533 E.12045
G1 X133.089 Y122.046 E.06433
M204 S10000
G1 X135.42 Y121.459 F42000
; LINE_WIDTH: 0.795367
G1 F3332.395
M204 S6000
G1 X134.927 Y121.435 E.07593
; LINE_WIDTH: 0.746107
G1 F3594.651
G1 X134.435 Y121.41 E.07039
; LINE_WIDTH: 0.726313
G1 F3712.036
G1 X134.201 Y121.407 E.03242
G1 X133.722 Y121.868 E.09199
; LINE_WIDTH: 0.758094
G1 F3527.102
G1 X133.62 Y121.935 E.01769
; LINE_WIDTH: 0.776796
G1 F3426.647
G1 X133.519 Y122.002 E.01821
G1 X133.76 Y121.972 E.03644
; LINE_WIDTH: 0.729257
G1 F3694.096
G1 X134.303 Y122 E.07559
; LINE_WIDTH: 0.732039
G1 F3677.302
G1 X134.65 Y122.056 E.04901
; LINE_WIDTH: 0.767222
G1 F3477.347
G1 X134.997 Y122.111 E.05183
; LINE_WIDTH: 0.817596
G1 F3226.183
G1 X135.343 Y122.167 E.05586
G1 X135.954 Y122.43 E.10575
G1 X136.347 Y122.783 E.08415
G1 X136.452 Y123.063 E.04752
G1 X136.391 Y123.562 E.07994
G1 X136.238 Y123.728 E.03601
; LINE_WIDTH: 0.842262
G1 F3115.977
G1 X136.197 Y123.753 E.00784
; LINE_WIDTH: 0.886792
G1 F2934.98
G1 X136.156 Y123.777 E.00832
; LINE_WIDTH: 0.931322
G1 F2773.857
G1 X136.116 Y123.802 E.0088
; LINE_WIDTH: 0.975852
G1 F2629.503
G1 X136.075 Y123.826 E.00928
; LINE_WIDTH: 1.02038
G1 F2499.431
G1 X136.034 Y123.851 E.00977
; LINE_WIDTH: 1.06491
G1 F2381.621
G1 X135.993 Y123.876 E.01025
; LINE_WIDTH: 1.10944
G1 F2274.416
G1 X135.953 Y123.9 E.01073
; LINE_WIDTH: 1.15397
G1 F2176.447
G1 X135.912 Y123.925 E.01121
G1 X135.956 Y123.972 E.01528
; LINE_WIDTH: 1.10944
G1 F2274.416
G1 X135.999 Y124.02 E.01462
; LINE_WIDTH: 1.06491
G1 F2381.621
G1 X136.043 Y124.068 E.01396
; LINE_WIDTH: 1.02038
G1 F2499.431
G1 X136.087 Y124.116 E.01331
; LINE_WIDTH: 0.975852
G1 F2629.503
G1 X136.13 Y124.164 E.01265
; LINE_WIDTH: 0.931322
G1 F2773.857
G1 X136.174 Y124.212 E.01199
; LINE_WIDTH: 0.886792
G1 F2934.98
G1 X136.218 Y124.259 E.01133
; LINE_WIDTH: 0.820087
G1 F3214.701
G1 X136.261 Y124.307 E.01034
G3 X137.421 Y125.054 I-7.11 J12.32 E.22039
G1 X137.481 Y124.625 E.06913
G1 X137.651 Y124.535 E.03065
G1 X137.917 Y124.586 E.04329
G1 X138.185 Y124.785 E.05329
G1 X138.428 Y125.114 E.06534
G1 X138.645 Y125.573 E.08101
G1 X138.955 Y126.455 E.14941
G3 X138.971 Y129.483 I-6.049 J1.545 E.48827
G3 X138.5 Y130.749 I-6.706 J-1.77 E.21614
G1 X138.196 Y131.2 E.0868
G1 X137.919 Y131.414 E.05602
G1 X137.651 Y131.466 E.04354
G1 X137.473 Y131.367 E.03252
G1 X137.424 Y130.944 E.06789
G3 X135.529 Y132.061 I-6.088 J-8.166 E.3519
G1 X135.813 Y132.339 E.06352
G1 X135.913 Y132.269 E.01953
G1 X136.26 Y132.289 E.05558
G1 X136.409 Y132.5 E.04124
G1 X136.45 Y132.936 E.06991
G1 X136.346 Y133.216 E.04774
G1 X135.971 Y133.562 E.08143
G1 X135.234 Y133.866 E.12728
; LINE_WIDTH: 0.803122
G1 F3294.555
G1 X134.926 Y133.912 E.04853
; LINE_WIDTH: 0.769372
G1 F3465.831
G1 X134.618 Y133.957 E.04613
; LINE_WIDTH: 0.7348
G1 F3660.782
G3 X133.698 Y134.023 I-.738 J-3.89 E.12971
; LINE_WIDTH: 0.762557
G1 F3502.6
G1 X133.59 Y134.007 E.01595
; LINE_WIDTH: 0.779329
G1 F3413.475
G1 X133.482 Y133.992 E.01636
G1 X133.672 Y134.09 E.03212
; LINE_WIDTH: 0.726961
G1 F3708.074
G3 X134.198 Y134.594 I-22.612 J24.148 E.10093
; LINE_WIDTH: 0.73028
G1 F3687.9
G1 X134.549 Y134.576 E.04887
; LINE_WIDTH: 0.766167
G1 F3483.026
G1 X134.9 Y134.558 E.05175
; LINE_WIDTH: 0.819692
G1 F3216.512
G1 X135.25 Y134.541 E.05604
G1 X137.203 Y134.541 E.3117
G1 X139.675 Y132.499 E.51168
G1 X140.28 Y131.896 E.13633
G1 X140.8 Y131.245 E.133
G1 X141.265 Y130.477 E.14322
G1 X141.619 Y129.619 E.1482
G1 X141.815 Y128.754 E.14159
G2 X141.801 Y127.194 I-5.454 J-.732 E.24987
G1 X141.601 Y126.335 E.14066
G1 X141.242 Y125.485 E.14735
G1 X140.778 Y124.729 E.14151
G2 X139.669 Y123.496 I-6.263 J4.519 E.26522
G1 X137.188 Y121.459 E.51234
G1 X135.54 Y121.459 E.26304
M204 S10000
G1 X141.011 Y127.772 F42000
; LINE_WIDTH: 1.10441
G1 F2286.051
M204 S6000
G2 X140.793 Y126.555 I-7.154 J.651 E.27792
; LINE_WIDTH: 1.06766
G1 F2374.708
G1 X140.707 Y126.319 E.0543
; LINE_WIDTH: 1.04189
G1 F2441.102
G1 X140.622 Y126.083 E.05282
; LINE_WIDTH: 1.00597
G1 F2540.091
G1 X140.397 Y125.637 E.10098
; LINE_WIDTH: 0.959902
G1 F2679.449
G1 X140.172 Y125.191 E.09573
; LINE_WIDTH: 0.920019
G1 F2813.057
G1 X140.023 Y124.979 E.04717
; LINE_WIDTH: 0.886322
G1 F2936.781
G1 X139.875 Y124.767 E.04518
; LINE_WIDTH: 0.852625
G1 F3071.889
G1 X139.727 Y124.555 E.04319
; LINE_WIDTH: 0.81657
G1 F3230.937
G1 X139.479 Y124.28 E.05895
; LINE_WIDTH: 0.778154
G1 F3419.57
G1 X139.23 Y124.004 E.0557
; LINE_WIDTH: 0.748677
G1 F3579.952
G1 X138.832 Y123.662 E.07524
; LINE_WIDTH: 0.760133
G1 F3515.867
G1 X138.642 Y123.534 E.03344
; LINE_WIDTH: 0.803585
G1 F3292.323
G1 X138.452 Y123.406 E.03571
; LINE_WIDTH: 0.847037
G1 F3095.507
G1 X138.262 Y123.279 E.03798
; LINE_WIDTH: 0.890489
G1 F2920.894
G1 X138.073 Y123.151 E.04025
; LINE_WIDTH: 0.933941
G1 F2764.93
G1 X137.883 Y123.023 E.04252
; LINE_WIDTH: 0.966666
G1 F2658.038
G1 X136.965 Y122.293 E.22646
G1 X137.217 Y123.127 E.16819
G1 X137.158 Y123.68 E.10752
G1 X137.071 Y123.896 E.04488
G1 X137.149 Y123.919 E.01567
G1 X137.491 Y123.784 E.07094
G1 X137.646 Y123.763 E.03033
; LINE_WIDTH: 0.930741
G1 F2775.846
G1 X137.791 Y123.82 E.02872
; LINE_WIDTH: 0.880888
G1 F2957.758
G1 X137.935 Y123.877 E.02695
; LINE_WIDTH: 0.831036
G1 F3165.186
G1 X138.08 Y123.934 E.02518
; LINE_WIDTH: 0.781183
G1 F3403.902
G1 X138.224 Y123.991 E.02342
; LINE_WIDTH: 0.754072
G1 F3549.484
G1 X138.711 Y124.378 E.09006
; LINE_WIDTH: 0.76699
G1 F3478.597
G1 X138.884 Y124.598 E.04122
; LINE_WIDTH: 0.797195
G1 F3323.4
G1 X139.057 Y124.817 E.04315
; LINE_WIDTH: 0.829369
G1 F3172.623
G1 X139.181 Y125.039 E.04113
; LINE_WIDTH: 0.863514
G1 F3026.889
G1 X139.305 Y125.261 E.04311
; LINE_WIDTH: 0.902657
G1 F2875.473
G1 X139.439 Y125.572 E.06039
; LINE_WIDTH: 0.946797
G1 F2721.928
G1 X139.573 Y125.882 E.0638
; LINE_WIDTH: 0.990937
G1 F2583.95
G1 X139.707 Y126.193 E.06721
; LINE_WIDTH: 1.02989
G1 F2473.302
G1 X139.793 Y126.514 E.06898
; LINE_WIDTH: 1.06366
G1 F2384.776
G1 X139.88 Y126.835 E.07154
; LINE_WIDTH: 1.11165
G1 F2269.35
G1 X139.991 Y127.553 E.16451
G3 X139.94 Y128.879 I-5.777 J.438 E.30068
; LINE_WIDTH: 1.08327
G1 F2336.224
G1 X139.851 Y129.259 E.08576
; LINE_WIDTH: 1.04929
G1 F2421.653
G1 X139.762 Y129.638 E.08273
; LINE_WIDTH: 1.01429
G1 F2516.448
G1 X139.655 Y129.933 E.06384
; LINE_WIDTH: 0.97827
G1 F2622.095
G1 X139.548 Y130.227 E.06127
; LINE_WIDTH: 0.940819
G1 F2741.757
G1 X139.418 Y130.493 E.05544
; LINE_WIDTH: 0.901942
G1 F2878.103
G1 X139.287 Y130.758 E.05281
; LINE_WIDTH: 0.863065
G1 F3028.719
G1 X139.157 Y131.024 E.05019
; LINE_WIDTH: 0.822744
G1 F3202.539
G1 X138.951 Y131.303 E.05555
; LINE_WIDTH: 0.78098
G1 F3404.951
G1 X138.746 Y131.582 E.05225
; LINE_WIDTH: 0.747561
G1 F3586.322
G3 X138.288 Y131.967 I-1.658 J-1.509 E.08587
; LINE_WIDTH: 0.770807
G1 F3458.187
G1 X138.16 Y132.022 E.02068
; LINE_WIDTH: 0.812367
G1 F3250.553
G1 X138.032 Y132.076 E.022
; LINE_WIDTH: 0.853927
G1 F3066.44
G1 X137.904 Y132.13 E.02332
; LINE_WIDTH: 0.895487
G1 F2902.065
G1 X137.775 Y132.185 E.02464
; LINE_WIDTH: 0.95706
G1 F2688.547
G1 X137.647 Y132.239 E.02659
G3 X137.108 Y132.082 I.21 J-1.722 E.10765
G1 X137.07 Y132.105 E.00842
G1 X137.157 Y132.321 E.04436
G1 X137.216 Y132.871 E.10565
G1 X136.885 Y133.769 E.18275
G1 X136.932 Y133.768 E.00893
G1 X137.885 Y132.98 E.23614
; LINE_WIDTH: 0.937047
G1 F2754.416
G1 X138.041 Y132.878 E.03466
; LINE_WIDTH: 0.895487
G1 F2902.065
G1 X138.197 Y132.777 E.0329
; LINE_WIDTH: 0.853927
G1 F3066.44
G1 X138.352 Y132.675 E.03114
; LINE_WIDTH: 0.812367
G1 F3250.553
G1 X138.508 Y132.573 E.02937
; LINE_WIDTH: 0.753269
G1 F3553.987
G2 X139.116 Y132.101 I-1.873 J-3.039 E.11137
; LINE_WIDTH: 0.759562
G1 F3519.007
G1 X139.334 Y131.873 E.04609
; LINE_WIDTH: 0.787992
G1 F3369.197
G1 X139.553 Y131.645 E.04814
; LINE_WIDTH: 0.824894
G1 F3192.773
G1 X139.755 Y131.373 E.05446
; LINE_WIDTH: 0.870267
G1 F2999.64
G1 X139.957 Y131.102 E.05796
; LINE_WIDTH: 0.91564
G1 F2828.54
G1 X140.159 Y130.83 E.06147
; LINE_WIDTH: 0.958467
G1 F2684.035
G1 X140.345 Y130.487 E.07459
; LINE_WIDTH: 0.998747
G1 F2560.98
G1 X140.531 Y130.144 E.07817
; LINE_WIDTH: 1.03589
G1 F2457.103
G1 X140.674 Y129.763 E.08512
; LINE_WIDTH: 1.06989
G1 F2369.126
G1 X140.816 Y129.381 E.08828
; LINE_WIDTH: 1.11391
G1 F2264.184
G1 X140.98 Y128.592 E.18282
G1 X141.006 Y127.892 E.15881
M204 S10000
G1 X133.239 Y133.962 F42000
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X133.363 Y133.977 E.01948
M204 S10000
G1 X132.517 Y134.268 F42000
; LINE_WIDTH: 0.760308
G1 F3514.905
M204 S6000
G1 X132.992 Y134.034 E.07733
G1 X133.239 Y133.962 E.03749
G1 X132.985 Y133.95 E.03706
G1 X132.477 Y133.8 E.07733
G1 X131.939 Y133.481 E.09134
G1 X131.939 Y134.487 E.147
G1 X132.013 Y134.53 E.0124
G1 X132.411 Y134.323 E.06546
M204 S10000
G1 X112.208 Y134.521 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.448 J-7.223 E.4465
G1 X122.192 Y120.612 E2.65867
G2 X119.598 Y119.598 I-4.767 J8.372 E.4462
G1 X129.374 Y129.374 E2.20756
G1 X130.446 Y128.003 E.27794
G1 X129.367 Y126.633 E.27849
G1 X119.602 Y136.398 E2.20503
G2 X122.192 Y135.388 I-2.113 J-9.245 E.4454
G1 X110.418 Y123.614 E2.65867
G3 X112.208 Y121.479 I8.248 J5.095 E.44652
; CHANGE_LAYER
; Z_HEIGHT: 3.76
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.089 Y122.641 E-.61313
G1 X110.87 Y122.959 E-.14688
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 7/51
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z3.76 I-.042 J1.703 P1  F42000
G1 X132.214 Y123.483 Z3.76
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X134.796 Y120.957 E.57667
G1 X137.926 Y123.535 E.64746
G1 X138.532 Y124.14 E.13679
G1 X139.094 Y124.847 E.14413
G1 X139.563 Y125.643 E.14748
G1 X139.911 Y126.536 E.15302
G1 X140.098 Y127.503 E.15731
G1 X140.098 Y128.497 E.15868
G1 X139.911 Y129.461 E.1568
G1 X139.565 Y130.352 E.15267
G1 X139.087 Y131.162 E.15015
G1 X138.542 Y131.849 E.14009
G1 X137.935 Y132.457 E.13714
G1 X134.799 Y135.045 E.64929
G1 X129.737 Y130.115 E1.12826
G1 X131.389 Y128.001 E.42847
G1 X129.739 Y125.905 E.42597
G1 X132.129 Y123.567 E.53389
M204 S10000
G1 X132.704 Y123.983 F42000
G1 F3215.099
M204 S6000
G1 X134.836 Y121.897 E.47633
G1 X137.455 Y124.054 E.54175
G3 X138.516 Y125.244 I-4.676 J5.236 E.2551
G1 X138.931 Y125.949 E.13067
M73 P50 R8
G1 X139.236 Y126.731 E.13394
G1 X139.398 Y127.57 E.13647
G1 X139.398 Y128.43 E.13729
G1 X139.236 Y129.266 E.13606
G1 X138.934 Y130.045 E.13346
G3 X137.464 Y131.939 I-5.813 J-2.995 E.38493
G1 X134.838 Y134.106 E.54368
G1 X130.675 Y130.052 E.92784
G1 X132.279 Y128 E.41593
G1 X130.677 Y125.966 E.4133
G1 X132.618 Y124.067 E.43355
; WIPE_START
G1 X134.048 Y122.668 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.596 Y124.895 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X134.394 Y125.556 E.16545
G3 X135.389 Y126.824 I-3.243 J3.572 E.25856
G3 X135.39 Y129.174 I-2.409 J1.176 E.38842
G3 X134.391 Y130.446 I-4.31 J-2.357 E.25956
G1 X133.596 Y131.103 E.16465
G1 X133.596 Y125.015 E.97212
; WIPE_START
M204 S6000
G1 X134.394 Y125.556 E-.36632
G1 X134.806 Y125.972 E-.22238
G1 X135.085 Y126.326 E-.1713
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.038 Y123.178 Z4.16 F42000
G1 X147.38 Y120.76 Z4.16
G1 Z3.76
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.523 Y135.24 E3.8095
G3 X121.61 Y136.365 I-7.902 J-11.251 E.35458
G3 X122.578 Y120.147 I-3.804 J-8.365 E6.0369
G1 X123.523 Y120.76 E.17973
G1 X147.26 Y120.76 E3.79034
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88818
G3 X120.232 Y137.587 I-6.319 J-8.881 E.62056
G3 X118.328 Y118.127 I-2.426 J-9.586 E5.43485
G3 X122.942 Y119.549 I-.507 J9.844 E.77885
G1 X123.73 Y120.06 E.14996
G1 X147.96 Y120.06 E3.86902
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96686
G3 X111.286 Y136.341 I-6.124 J-8.665 E2.16482
G3 X111.286 Y119.659 I6.519 J-8.341 E3.06763
G3 X118.357 Y117.428 I6.519 J8.341 E1.2095
G3 X123.937 Y119.36 I-.583 J10.708 E.9552
G1 X148.66 Y119.36 E3.9477
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.16 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.16
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.16 F4000
            G39.3 S1
            G0 Z4.16 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X138.713 Y126.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.832057
G1 F3160.645
M204 S2000
G1 X137.283 Y124.73 E.32854
G1 X136.624 Y124.412 E.11882
G1 X136.421 Y124.111 E.059
G1 X136.414 Y123.967 E.02337
G1 X134.87 Y122.696 E.32489
G1 X134.552 Y123.007 E.07225
G1 X138.714 Y127.169 E.95604
G1 X138.803 Y127.627 E.07577
G1 X138.803 Y128.264 E.10352
G1 X134.044 Y123.505 E1.09326
G1 X133.535 Y124.003 E.11563
G1 X138.654 Y129.122 E1.17593
G1 X138.365 Y129.839 E.12564
G1 X136.258 Y127.733 E.48382
G3 X136.185 Y128.667 I-2.799 J.25 E.15282
G1 X137.985 Y130.467 E.41354
G1 X137.536 Y131.024 E.11629
G1 X135.932 Y129.421 E.36836
G1 X135.637 Y129.93 E.09572
G1 X135.548 Y130.043 E.02328
G1 X136.946 Y131.441 E.32102
G1 X136.619 Y131.59 E.05845
G1 X136.416 Y131.891 E.05894
G1 X136.415 Y131.916 E.00408
G1 X135.088 Y130.589 E.3048
G3 X134.565 Y131.074 I-2.742 J-2.433 E.11589
G1 X135.927 Y132.436 E.31282
G1 X135.376 Y132.891 E.11616
G1 X133.79 Y131.305 E.36414
; WIPE_START
M204 S6000
M73 P51 R8
G1 X135.205 Y132.72 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.316 Y128.818 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
G1 F3160.645
M204 S2000
G1 X132.94 Y128.442 E.08642
G1 X132.587 Y128.572 E.06115
G1 X132.357 Y128.865 E.06056
G1 X133.001 Y129.51 E.14796
G1 X133.001 Y130.516 E.16352
G1 X131.915 Y129.431 E.2494
G1 X131.474 Y129.996 E.11649
G1 X135.048 Y133.57 E.82096
; WIPE_START
M204 S6000
G1 X133.634 Y132.155 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.316 Y125.797 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
G1 F3160.645
M204 S2000
G1 X132.517 Y124.998 E.18357
G1 X132.008 Y125.496 E.11563
G1 X133.001 Y126.489 E.22812
G1 X133.001 Y127.485 E.16176
G1 X131.277 Y125.771 E.39491
; WIPE_START
M204 S6000
G1 X132.695 Y127.181 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.507 Y121.459 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.114
M204 S6000
G1 X138.384 Y123.005 E.3883
G1 X139.041 Y123.659 E.14799
G1 X139.657 Y124.43 E.15759
G1 X140.18 Y125.312 E.16372
G3 X140.588 Y126.356 I-38.392 J15.621 E.17892
G3 X140.798 Y127.485 I-29.002 J5.957 E.18347
G1 X140.798 Y128.53 E.16684
G1 X140.592 Y129.624 E.17778
G3 X140.207 Y130.632 I-47.347 J-17.511 E.17224
G3 X139.078 Y132.299 I-7.632 J-3.953 E.32231
G1 X138.419 Y132.963 E.14943
G3 X136.51 Y134.541 I-167.301 J-200.525 E.39534
G1 X138.919 Y134.541 E.38463
G1 X141.39 Y132.506 E.51112
G1 X141.993 Y131.907 E.13577
G1 X142.515 Y131.256 E.13323
G2 X143.338 Y129.634 I-6.252 J-4.19 E.29111
G2 X143.541 Y127.255 I-5.469 J-1.665 E.38407
G1 X143.319 Y126.316 E.15405
G1 X142.957 Y125.469 E.14706
G1 X142.492 Y124.716 E.1413
G2 X141.354 Y123.464 I-6.262 J4.546 E.27076
G1 X138.904 Y121.459 E.50548
G1 X136.627 Y121.459 E.36358
M204 S10000
G1 X139.712 Y123.174 F42000
; LINE_WIDTH: 1.04398
G1 F2435.577
M204 S6000
G1 X139.676 Y123.145 E.00972
G1 X140.292 Y123.925 E.20935
G1 X140.879 Y124.901 E.24006
G3 X141.376 Y126.165 I-16.824 J7.352 E.28633
; LINE_WIDTH: 1.02026
G1 F2499.756
G1 X141.381 Y126.304 E.02864
; LINE_WIDTH: 0.975761
G1 F2629.783
G1 X141.386 Y126.443 E.02723
; LINE_WIDTH: 0.931257
G1 F2774.079
G1 X141.39 Y126.583 E.02581
; LINE_WIDTH: 0.886753
G1 F2935.13
G1 X141.395 Y126.722 E.02439
; LINE_WIDTH: 0.821536
G1 F3208.056
G1 X141.399 Y126.861 E.02232
G1 X141.496 Y127.407 E.08865
G3 X141.478 Y128.729 I-17.856 J.428 E.21167
; LINE_WIDTH: 0.833587
G1 F3153.867
G1 X141.392 Y129.246 E.08524
; LINE_WIDTH: 0.860767
G1 F3038.118
G1 X141.306 Y129.762 E.08848
; LINE_WIDTH: 0.898622
G1 F2890.378
G1 X141.311 Y129.833 E.01255
; LINE_WIDTH: 0.947152
G1 F2720.759
G1 X141.316 Y129.903 E.01333
; LINE_WIDTH: 1.01044
G1 F2527.338
G1 X141.321 Y129.974 E.01435
G1 X140.948 Y130.919 E.20644
G3 X140.272 Y132.071 I-14.835 J-7.927 E.27119
; LINE_WIDTH: 1.02323
G1 F2491.536
G1 X139.998 Y132.441 E.09494
; LINE_WIDTH: 1.04303
G1 F2438.088
G1 X139.724 Y132.811 E.09703
G1 X140.454 Y132.249 E.19405
; LINE_WIDTH: 1.00953
G1 F2529.935
G2 X141.869 Y130.793 I-4.954 J-6.233 E.41311
G1 X142.128 Y130.364 E.10168
; LINE_WIDTH: 0.995682
G1 F2569.945
G1 X142.207 Y130.27 E.02454
; LINE_WIDTH: 0.947152
G1 F2720.759
G1 X142.286 Y130.175 E.02318
; LINE_WIDTH: 0.898622
G1 F2890.378
G1 X142.365 Y130.081 E.02182
; LINE_WIDTH: 0.860767
G1 F3038.118
G1 X142.511 Y129.765 E.05882
; LINE_WIDTH: 0.821427
G1 F3208.558
G1 X142.657 Y129.449 E.05569
G1 X142.845 Y128.66 E.12988
G1 X142.889 Y127.794 E.13875
G2 X142.651 Y126.536 I-6.32 J.543 E.2052
; LINE_WIDTH: 0.843603
G1 F3110.2
G1 X142.562 Y126.386 E.02872
; LINE_WIDTH: 0.890816
G1 F2919.656
G1 X142.473 Y126.237 E.03059
; LINE_WIDTH: 0.938028
G1 F2751.112
G1 X142.383 Y126.088 E.03247
; LINE_WIDTH: 0.985241
G1 F2600.965
G1 X142.294 Y125.938 E.03434
; LINE_WIDTH: 1.04011
G1 F2445.839
G1 X141.843 Y125.209 E.18001
G1 X141.484 Y124.762 E.12027
G1 X140.818 Y124.074 E.20111
G1 X139.806 Y123.25 E.27398
M204 S10000
G1 X142.035 Y126.739 F42000
; LINE_WIDTH: 0.735297
G1 F3657.823
M204 S6000
G1 X142.162 Y127.367 E.09006
; LINE_WIDTH: 0.770062
G1 F3462.151
G1 X142.178 Y127.773 E.06023
; LINE_WIDTH: 0.786929
G1 F3374.568
G1 X142.193 Y128.179 E.0618
G1 X142.131 Y128.855 E.1033
; LINE_WIDTH: 0.738347
G1 F3639.776
G1 X142.08 Y129.081 E.03265
M204 S10000
G1 X138.644 Y133.774 F42000
; LINE_WIDTH: 0.977157
G1 F2625.499
M204 S6000
G1 X139.135 Y133.339 E.12835
; LINE_WIDTH: 1.02376
G1 F2490.095
G1 X139.627 Y132.904 E.13533
; LINE_WIDTH: 1.05742
G1 F2400.666
G1 X139.637 Y132.894 E.00299
; WIPE_START
G1 X139.627 Y132.904 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.919 Y125.304 Z4.16 F42000
G1 X138.632 Y122.222 Z4.16
G1 Z3.76
G1 E.8 F1800
; LINE_WIDTH: 0.968827
G1 F2651.27
M204 S6000
G1 X139.11 Y122.643 E.12339
; LINE_WIDTH: 1.01649
G1 F2510.292
G1 X139.588 Y123.064 E.13032
M204 S10000
G1 X145.042 Y134.646 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X146.786 Y134.646 E.27836
G1 X146.786 Y133.59 E.16861
G1 X143.725 Y130.529 E.69112
G2 X143.73 Y125.466 I-5.351 J-2.538 E.83541
G1 X146.786 Y122.41 E.68988
G1 X146.786 Y121.354 E.16861
G1 X145.042 Y121.354 E.27836
; WIPE_START
G1 X146.786 Y121.354 E-.66246
G1 X146.786 Y121.611 E-.09754
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.153 Y121.582 Z4.16 F42000
G1 X112.209 Y121.479 Z4.16
G1 Z3.76
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I6.458 J7.232 E.44653
G1 X122.192 Y135.388 E2.65866
G3 X119.598 Y136.402 I-4.766 J-8.37 E.4462
G1 X129.472 Y126.528 E2.2296
G1 X130.633 Y128.003 E.2997
G1 X129.479 Y129.479 E.29924
G1 X119.598 Y119.598 E2.23121
G3 X122.192 Y120.612 I-2.173 J9.384 E.44621
G1 X110.418 Y132.386 E2.65866
G2 X112.208 Y134.521 I8.237 J-5.086 E.4465
; CHANGE_LAYER
; Z_HEIGHT: 4.32
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.153 Y133.442 E-.57352
G1 X110.873 Y133.039 E-.18649
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 8/51
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z4.32 I.679 J1.563 P1  F42000
G1 X132.014 Y123.86 Z4.32
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.014 Y121.556 E.36783
G1 X134.556 Y122.876 E.45729
G1 X136.506 Y120.955 E.43712
G1 X139.634 Y123.521 E.64605
G1 X140.208 Y124.091 E.12909
G1 X140.41 Y124.329 E.04983
G3 X141.822 Y128.254 I-4.276 J3.756 E.68197
G3 X140.773 Y131.211 I-5.767 J-.382 E.50738
G1 X140.255 Y131.86 E.13255
G1 X139.653 Y132.462 E.13588
G1 X136.52 Y135.05 E.64894
G1 X134.555 Y133.125 E.4393
G1 X132.014 Y134.444 E.45712
G1 X132.014 Y130.635 E.60817
G1 X131.455 Y130.087 E.12509
G1 X132.014 Y129.381 E.14387
G1 X132.014 Y126.628 E.43956
G1 X131.458 Y125.929 E.14273
G1 X132.014 Y125.38 E.12477
G1 X132.014 Y123.98 E.22355
M204 S10000
G1 X132.714 Y123.86 F42000
G1 F3215.099
M204 S6000
G1 X132.714 Y122.708 E.18392
G1 X134.685 Y123.731 E.35457
G1 X136.549 Y121.895 E.41781
G1 X139.165 Y124.041 E.54023
G3 X140.34 Y125.412 I-5.42 J5.838 E.28903
G3 X140.611 Y130.125 I-3.89 J2.587 E.79026
G3 X139.182 Y131.943 I-5.894 J-3.162 E.37103
G1 X136.56 Y134.109 E.54308
G1 X134.683 Y132.27 E.41971
G1 X132.714 Y133.292 E.35415
G1 X132.714 Y130.341 E.47118
G1 X132.394 Y130.028 E.07147
G1 X132.714 Y129.624 E.0822
G1 X132.714 Y126.383 E.51751
G1 X132.397 Y125.985 E.08126
G1 X132.714 Y125.673 E.07104
G1 X132.714 Y123.98 E.27032
M204 S250
G1 X133.414 Y123.86 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X134.478 Y124.412 E.19138
G3 X135.629 Y125.153 I-4.769 J8.675 E.21883
G3 X136.837 Y126.361 I-3.704 J4.911 E.27352
G3 X137.379 Y128.282 I-2.336 J1.697 E.32554
G3 X136.515 Y130.045 I-3.308 J-.529 E.31817
G3 X135.092 Y131.221 I-5.653 J-5.392 E.29547
G3 X133.414 Y132.14 I-8.518 J-13.555 E.30561
G1 X133.414 Y123.98 E1.30294
; WIPE_START
M204 S6000
G1 X134.478 Y124.412 E-.43631
G1 X135.087 Y124.776 E-.26974
G1 X135.204 Y124.857 E-.05394
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.437 Y122.423 Z4.72 F42000
G1 X147.38 Y120.76 Z4.72
G1 Z4.32
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.522 Y135.24 E3.80952
G3 X121.612 Y136.364 I-8.033 J-11.473 E.35427
G3 X122.58 Y120.148 I-3.805 J-8.364 E6.03735
G1 X123.522 Y120.76 E.17943
G1 X147.26 Y120.76 E3.79036
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.73 Y135.94 E3.88819
G3 X120.234 Y137.587 I-6.319 J-8.881 E.62032
G3 X118.298 Y118.126 I-2.428 J-9.585 E5.43039
G3 X122.943 Y119.55 I-.477 J9.844 E.7838
G1 X123.73 Y120.06 E.14965
G1 X147.96 Y120.06 E3.86903
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z4.72 F42000
G1 Z4.32
M73 P52 R8
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96686
G3 X111.263 Y136.323 I-6.124 J-8.658 E2.16962
G3 X111.263 Y119.677 I6.542 J-8.323 E3.05822
G3 X118.328 Y117.427 I6.546 J8.336 E1.2094
G3 X123.937 Y119.36 I-.552 J10.704 E.95984
G1 X148.66 Y119.36 E3.9477
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.72 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.72
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.72 F4000
            G39.3 S1
            G0 Z4.72 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X145.042 Y121.354 F42000
G1 Z4.32
M73 P52 R7
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G1 X146.786 Y121.354 E.27836
G1 X146.786 Y122.41 E.16861
G1 X144.825 Y124.371 E.44265
G3 X144.829 Y131.633 I-4.967 J3.634 E1.24034
G1 X146.786 Y133.59 E.4418
G1 X146.786 Y130.79 E.44698
; WIPE_START
G1 X146.786 Y132.79 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.426 Y129.853 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828507
G1 F3176.486
M204 S2000
G1 X138.749 Y131.529 E.38324
G1 X136.594 Y133.31 E.45179
G1 X136.277 Y133 E.07165
G1 X140.437 Y128.84 E.95081
G2 X140.526 Y127.749 I-3.291 J-.818 E.17764
G1 X135.771 Y132.504 E1.0868
G1 X135.265 Y132.008 E.11448
G1 X140.374 Y126.899 E1.16764
G2 X140.093 Y126.179 I-5.546 J1.748 E.12511
G1 X137.975 Y128.297 E.4841
G2 X137.915 Y127.355 I-2.952 J-.286 E.15319
G1 X139.72 Y125.55 E.41242
G2 X139.275 Y124.993 I-10.073 J7.574 E.11522
G1 X137.664 Y126.604 E.36824
G2 X137.29 Y125.976 I-7.549 J4.066 E.11815
G1 X138.774 Y124.492 E.33919
G1 X138.225 Y124.04 E.11501
G1 X136.833 Y125.432 E.3182
G2 X136.315 Y124.948 I-2.771 J2.444 E.11472
G1 X137.675 Y123.588 E.31075
G1 X137.125 Y123.137 E.11503
G1 X135.749 Y124.512 E.3144
G2 X135.143 Y124.117 I-3.157 J4.177 E.11708
G1 X136.798 Y122.461 E.37834
; WIPE_START
M204 S6000
G1 X135.384 Y123.876 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.225 Y121.459 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X140.122 Y123.019 E.39211
G1 X140.933 Y123.865 E.1872
G1 X141.515 Y124.651 E.15615
G3 X142.346 Y126.546 I-7.203 J4.293 E.33118
G3 X142.487 Y128.724 I-7.131 J1.553 E.34983
G1 X142.291 Y129.634 E.14869
G3 X141.871 Y130.737 I-8.977 J-2.784 E.18846
G3 X140.79 Y132.312 I-7.829 J-4.213 E.30563
G1 X140.136 Y132.968 E.14801
G3 X138.236 Y134.541 I-171.656 J-205.587 E.39383
G1 X140.64 Y134.541 E.38387
G1 X143.107 Y132.512 E.51006
G1 X143.694 Y131.93 E.13193
G1 X144.238 Y131.256 E.13835
M73 P53 R7
G1 X144.699 Y130.5 E.14132
G1 X145.063 Y129.629 E.15074
G1 X145.272 Y128.71 E.15051
G2 X145.239 Y127.23 I-4.842 J-.633 E.23739
G2 X145.005 Y126.224 I-3.869 J.374 E.16531
G1 X144.679 Y125.465 E.13186
G1 X144.218 Y124.72 E.13996
G2 X143.076 Y123.462 I-6.246 J4.527 E.27181
G1 X140.652 Y121.459 E.50211
G1 X138.345 Y121.459 E.36838
M204 S10000
G1 X141.661 Y123.382 F42000
; LINE_WIDTH: 1.10514
G1 F2284.357
M204 S6000
G1 X141.59 Y123.331 E.01966
; LINE_WIDTH: 1.09711
G1 F2303.133
G1 X141.881 Y123.749 E.11363
; LINE_WIDTH: 1.05707
G1 F2401.562
G1 X142.173 Y124.168 E.10897
G3 X143.095 Y126.211 I-7.791 J4.747 E.4804
G1 X143.158 Y126.39 E.04068
; LINE_WIDTH: 1.04234
G1 F2439.911
G1 X143.148 Y126.484 E.01981
; LINE_WIDTH: 0.992932
G1 F2578.043
G1 X143.138 Y126.578 E.01875
; LINE_WIDTH: 0.943522
G1 F2732.755
G1 X143.128 Y126.671 E.01768
; LINE_WIDTH: 0.894112
G1 F2907.221
G1 X143.118 Y126.765 E.01662
; LINE_WIDTH: 0.820759
G1 F3211.615
G1 X143.108 Y126.859 E.01505
G1 X143.211 Y127.526 E.10791
G3 X143.186 Y128.748 I-22.103 J.163 E.19536
G1 X142.974 Y129.786 E.16938
; LINE_WIDTH: 0.84248
G1 F3115.038
G1 X142.973 Y129.874 E.01455
; LINE_WIDTH: 0.887444
G1 F2932.484
G1 X142.972 Y129.962 E.01546
; LINE_WIDTH: 0.93241
G1 F2770.143
G1 X142.971 Y130.051 E.01636
; LINE_WIDTH: 0.982071
G1 F2610.529
G1 X142.971 Y130.139 E.01736
G1 X142.591 Y131.032 E.19087
G3 X141.943 Y132.114 I-15.445 J-8.521 E.24807
; LINE_WIDTH: 0.999115
G1 F2559.909
G1 X141.688 Y132.469 E.08762
; LINE_WIDTH: 1.02811
G1 F2478.153
G1 X141.433 Y132.824 E.09051
G1 X142.135 Y132.303 E.18101
; LINE_WIDTH: 0.978817
G1 F2620.422
G2 X143.6 Y130.806 I-4.936 J-6.297 E.41151
G1 X143.753 Y130.535 E.06096
; LINE_WIDTH: 0.977374
G1 F2624.833
G1 X143.837 Y130.436 E.02546
; LINE_WIDTH: 0.93241
G1 F2770.143
G1 X143.922 Y130.338 E.02413
; LINE_WIDTH: 0.887444
G1 F2932.484
G1 X144.007 Y130.239 E.02279
; LINE_WIDTH: 0.820752
G1 F3211.649
G1 X144.092 Y130.14 E.02081
G1 X144.394 Y129.415 E.12551
G1 X144.579 Y128.603 E.13308
G1 X144.613 Y127.832 E.12334
G2 X144.475 Y126.88 I-17.489 J2.044 E.1539
G1 X144.361 Y126.5 E.06336
; LINE_WIDTH: 0.844702
G1 F3105.483
G1 X144.3 Y126.419 E.0168
; LINE_WIDTH: 0.894112
G1 F2907.221
G1 X144.238 Y126.338 E.01795
; LINE_WIDTH: 0.943522
G1 F2732.755
G1 X144.177 Y126.257 E.01909
; LINE_WIDTH: 0.992932
G1 F2578.043
G1 X144.115 Y126.176 E.02024
; LINE_WIDTH: 1.05447
G1 F2408.248
G1 X144.054 Y126.096 E.02167
G1 X143.934 Y125.813 E.06531
G1 X143.551 Y125.194 E.15518
G2 X142.528 Y124.069 I-5.59 J4.057 E.32478
; LINE_WIDTH: 1.07652
G1 F2352.72
G1 X141.755 Y123.456 E.2153
M204 S10000
G1 X143.757 Y126.759 F42000
; LINE_WIDTH: 0.752337
G1 F3559.226
M204 S6000
G1 X143.877 Y127.415 E.09626
; LINE_WIDTH: 0.784657
G1 F3386.107
G1 X143.893 Y127.786 E.05619
; LINE_WIDTH: 0.800164
G1 F3308.887
G1 X143.91 Y128.156 E.0575
G1 X143.855 Y128.77 E.09572
; LINE_WIDTH: 0.742487
G1 F3615.561
G1 X143.792 Y129.098 E.04731
M204 S10000
G1 X140.365 Y133.775 F42000
; LINE_WIDTH: 0.975097
G1 F2631.825
M204 S6000
G1 X140.852 Y133.345 E.12655
; LINE_WIDTH: 1.02106
G1 F2497.558
G1 X141.338 Y132.916 E.13336
; LINE_WIDTH: 1.0542
G1 F2408.942
G1 X141.347 Y132.907 E.00266
; WIPE_START
G1 X141.338 Y132.916 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.653 Y125.314 Z4.72 F42000
G1 X140.375 Y122.229 Z4.72
G1 Z4.32
G1 E.8 F1800
; LINE_WIDTH: 0.962227
G1 F2672.05
M204 S6000
G1 X140.679 Y122.484 E.07631
; LINE_WIDTH: 0.988187
G1 F2592.136
G1 X140.954 Y122.739 E.07417
; LINE_WIDTH: 1.03349
G1 F2463.567
G1 X141.228 Y122.994 E.07805
; LINE_WIDTH: 1.07879
G1 F2347.149
G1 X141.502 Y123.249 E.08192
; WIPE_START
G1 X141.228 Y122.994 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.436 Y122.08 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
; LINE_WIDTH: 0.722577
G1 F3735.06
M204 S6000
G1 X135.116 Y121.411 E.13109
G1 X133.147 Y121.411 E.27061
G1 X134.33 Y122.025 E.18318
; WIPE_START
G1 X133.147 Y121.411 E-.50645
G1 X133.814 Y121.411 E-.25355
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.238 Y127.9 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
; LINE_WIDTH: 0.976597
G1 F2627.216
M204 S6000
G1 X131.236 Y128.058 E.03087
M204 S10000
G1 X131.238 Y127.9 F42000
; LINE_WIDTH: 0.953249
G1 F2700.848
M204 S6000
G1 X131.258 Y127.802 E.01908
; LINE_WIDTH: 0.912632
G1 F2839.278
G1 X131.278 Y127.703 E.01815
; LINE_WIDTH: 0.872015
G1 F2992.665
G1 X131.299 Y127.605 E.01722
; LINE_WIDTH: 0.81751
G1 F3226.58
G2 X131.319 Y126.871 I-10.986 J-.674 E.1169
G1 X130.719 Y126.114 E.15366
; LINE_WIDTH: 0.82611
G1 F3187.274
G1 X130.664 Y126.017 E.01807
; LINE_WIDTH: 0.861215
G1 F3036.284
G1 X130.609 Y125.919 E.01897
; LINE_WIDTH: 0.857504
G1 F3051.565
G1 X130.662 Y125.838 E.01625
; LINE_WIDTH: 0.814977
G1 F3238.342
G1 X130.714 Y125.756 E.01531
; LINE_WIDTH: 0.750929
G1 F3567.172
G1 X130.767 Y125.675 E.0139
G1 X131.35 Y125.102 E.1177
G1 X131.35 Y124.221 E.12672
G2 X130.324 Y125.225 I596.895 J610.562 E.20648
; LINE_WIDTH: 0.77245
G1 F3449.474
G1 X130.205 Y125.372 E.02822
; LINE_WIDTH: 0.814977
G1 F3238.342
G1 X130.085 Y125.519 E.03006
; LINE_WIDTH: 0.871172
G1 F2996.024
G3 X129.725 Y125.909 I-2.224 J-1.69 E.09101
; LINE_WIDTH: 0.861217
G1 F3036.273
G1 X129.951 Y126.224 E.06553
; LINE_WIDTH: 0.820255
G1 F3213.927
G2 X131.098 Y127.674 I18.157 J-13.184 E.29551
; LINE_WIDTH: 0.872015
G1 F2992.665
G1 X131.124 Y127.716 E.0083
; LINE_WIDTH: 0.912632
G1 F2839.278
G1 X131.149 Y127.757 E.00874
; LINE_WIDTH: 0.953249
G1 F2700.848
G1 X131.175 Y127.798 E.00919
M204 S10000
G1 X131.349 Y131.047 F42000
; LINE_WIDTH: 0.750659
G1 F3568.698
M204 S6000
G1 X131.349 Y130.915 E.01904
G1 X130.764 Y130.342 E.11781
; LINE_WIDTH: 0.772454
G1 F3449.457
G1 X130.711 Y130.261 E.01436
; LINE_WIDTH: 0.814847
G1 F3238.948
G1 X130.659 Y130.18 E.01529
; LINE_WIDTH: 0.84753
G1 F3093.409
G1 X130.606 Y130.099 E.01601
G1 X130.715 Y129.903 E.0373
; LINE_WIDTH: 0.809882
G1 F3262.263
G3 X131.319 Y129.139 I220.554 J173.625 E.15325
; LINE_WIDTH: 0.829597
G1 F3171.605
G1 X131.301 Y128.768 E.06005
; LINE_WIDTH: 0.866537
G1 F3014.631
G1 X131.282 Y128.398 E.06318
; LINE_WIDTH: 0.908665
G1 F2853.565
G1 X131.258 Y128.288 E.02021
; LINE_WIDTH: 0.95598
G1 F2692.023
G1 X131.235 Y128.178 E.02142
; LINE_WIDTH: 0.958573
G1 F2683.695
G1 X131.101 Y128.335 E.03939
; LINE_WIDTH: 0.916446
G1 F2825.679
G1 X130.968 Y128.492 E.03741
; LINE_WIDTH: 0.874318
G1 F2983.526
G1 X130.835 Y128.649 E.03543
; LINE_WIDTH: 0.814058
G1 F3242.629
G2 X130.172 Y129.481 I10.258 J8.852 E.16848
; LINE_WIDTH: 0.825824
G1 F3188.561
G1 X129.947 Y129.796 E.06232
; LINE_WIDTH: 0.8609
G1 F3037.575
G1 X129.723 Y130.112 E.06542
; LINE_WIDTH: 0.85724
G1 F3052.655
G1 X129.923 Y130.339 E.0509
; LINE_WIDTH: 0.814847
G1 F3238.948
G1 X130.123 Y130.566 E.04797
; LINE_WIDTH: 0.75321
G1 F3554.317
G2 X131.349 Y131.794 I17.591 J-16.349 E.25066
G1 X131.349 Y131.167 E.09049
; WIPE_START
G1 X131.349 Y131.794 E-.23808
G1 X130.366 Y130.835 E-.52192
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.119 Y134.589 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800
; LINE_WIDTH: 0.722677
G1 F3734.44
M204 S6000
G1 X134.436 Y133.92 E.13145
G1 X133.148 Y134.589 E.1996
G1 X134.999 Y134.589 E.25453
M204 S10000
G1 X112.209 Y134.521 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.46 J-7.233 E.44653
G1 X122.192 Y120.612 E2.65866
G2 X119.598 Y119.598 I-4.766 J8.37 E.44621
G1 X129.374 Y129.374 E2.20756
G1 X130.446 Y128.003 E.27794
G1 X129.367 Y126.633 E.27848
G1 X119.598 Y136.402 E2.20596
G2 X122.192 Y135.388 I-2.172 J-9.383 E.44621
G1 X110.418 Y123.614 E2.65865
G3 X112.209 Y121.479 I8.25 J5.097 E.44653
; CHANGE_LAYER
; Z_HEIGHT: 4.88
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.493 Y122.167 E-.37743
G1 X111.053 Y122.687 E-.2588
G1 X110.869 Y122.956 E-.12377
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 9/51
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z4.88 I-.015 J1.704 P1  F42000
G1 X131.832 Y123.136 Z4.88
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.832 Y121.153 E.31666
G1 X134.483 Y122.095 E.44921
G3 X136.287 Y122.88 I-7.803 J20.407 E.31425
G1 X138.235 Y120.967 E.43588
G1 X141.323 Y123.492 E.63683
G3 X142.158 Y124.359 I-6.711 J7.295 E.19234
G3 X143.547 Y127.715 I-4.359 J3.77 E.59007
G3 X142.487 Y131.224 I-5.631 J.214 E.59601
G1 X141.969 Y131.871 E.13243
G1 X141.369 Y132.469 E.13526
G1 X138.236 Y135.048 E.64799
G1 X136.285 Y133.13 E.43683
G3 X134.485 Y133.904 I-9.363 J-19.298 E.31296
G1 X131.832 Y134.848 E.44954
G1 X131.832 Y123.256 E1.8509
M204 S10000
G1 X132.532 Y123.136 F42000
G1 F3215.099
M204 S6000
G1 X132.532 Y122.144 E.15833
G1 X134.236 Y122.75 E.28866
G3 X136.415 Y123.735 I-6.806 J17.967 E.3822
G1 X138.278 Y121.906 E.41678
G1 X140.859 Y124.016 E.53232
G3 X142.081 Y125.44 I-4.628 J5.21 E.30052
G3 X142.328 Y130.137 I-3.904 J2.561 E.78714
G3 X140.899 Y131.95 I-5.957 J-3.229 E.37044
G1 X138.277 Y134.107 E.54209
G1 X136.408 Y132.268 E.41868
G3 X134.237 Y133.25 I-8.959 J-16.934 E.3807
G1 X132.532 Y133.856 E.28893
G1 X132.532 Y123.256 E1.69256
M204 S250
G1 X133.232 Y123.136 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X136.803 Y124.772 I-5.305 J16.298 E.62856
G3 X138.632 Y126.472 I-3.159 J5.231 E.40163
G3 X139.04 Y128.612 I-2.218 J1.532 E.35804
G3 X138.232 Y130.052 I-3.4 J-.962 E.26618
G3 X136.817 Y131.22 I-5.656 J-5.413 E.29366
G3 X133.232 Y132.864 I-8.882 J-14.632 E.6311
G1 X133.232 Y123.256 E1.53422
; WIPE_START
M204 S6000
G1 X133.988 Y123.405 E-.29276
G1 X134.79 Y123.726 E-.32822
G1 X135.122 Y123.878 E-.13903
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.519 Y121.996 Z5.28 F42000
G1 X147.38 Y120.76 Z5.28
G1 Z4.88
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X147.38 Y135.24 E2.31222
G1 X123.522 Y135.24 E3.80953
G3 X121.614 Y136.363 I-8.176 J-11.715 E.35396
G3 X122.581 Y120.149 I-3.807 J-8.363 E6.0378
G1 X123.522 Y120.76 E.17912
G1 X147.26 Y120.76 E3.79037
; WIPE_START
G1 X147.277 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.08 Y120.06 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.729 Y135.94 E3.8882
G3 X120.235 Y137.587 I-6.32 J-8.882 E.6201
G3 X118.269 Y118.125 I-2.429 J-9.585 E5.42585
G3 X122.945 Y119.551 I-.447 J9.844 E.78874
G1 X123.729 Y120.06 E.14935
G1 X147.96 Y120.06 E3.86904
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96687
G3 X118.299 Y117.426 I-6.127 J-8.637 E6.43305
G3 X123.937 Y119.36 I-.521 J10.702 E.96449
G1 X148.66 Y119.36 E3.94771
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.28 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.28
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z5.28 F4000
            G39.3 S1
            G0 Z5.28 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X146.681 Y121.459 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.113
M204 S6000
G1 X139.943 Y121.459 E1.07585
M73 P54 R7
G1 X141.776 Y122.958 E.37816
G1 X142.685 Y123.899 E.20878
G1 X143.162 Y124.55 E.12886
G1 X143.733 Y125.571 E.18677
G1 X144.09 Y126.629 E.17846
G1 X144.246 Y127.71 E.17438
G1 X144.208 Y128.743 E.16493
G1 X143.977 Y129.797 E.17243
G1 X143.589 Y130.747 E.16378
G1 X143.081 Y131.594 E.15777
G1 X142.503 Y132.324 E.14855
G3 X141.827 Y132.999 I-7.106 J-6.446 E.15265
G1 X139.954 Y134.541 E.38739
G1 X146.681 Y134.541 E1.07413
G1 X146.681 Y121.579 E2.06956
M204 S10000
G1 X141.905 Y122.159 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X142.54 Y122.718 E.13511
G1 X143.197 Y123.422 E.15375
G3 X144.418 Y125.398 I-6.602 J5.445 E.37203
; LINE_WIDTH: 0.836002
G1 F3143.227
G1 X144.594 Y125.866 E.08167
; LINE_WIDTH: 0.868012
G1 F3008.685
G1 X144.769 Y126.334 E.08532
; LINE_WIDTH: 0.907578
G1 F2857.501
G1 X144.804 Y126.378 E.00994
; LINE_WIDTH: 0.954701
G1 F2696.149
G1 X144.838 Y126.421 E.01054
; LINE_WIDTH: 1.00182
G1 F2552.044
G1 X144.873 Y126.464 E.01113
; LINE_WIDTH: 1.03497
G1 F2459.575
G1 X144.907 Y126.507 E.01155
G1 X145.022 Y127.529 E.21457
; LINE_WIDTH: 0.996083
G1 F2568.769
G1 X145.001 Y128.772 E.24857
G1 X144.961 Y128.977 E.0418
; LINE_WIDTH: 0.960417
G1 F2677.806
G1 X144.885 Y129.221 E.04884
; LINE_WIDTH: 0.920297
G1 F2812.078
G1 X144.81 Y129.464 E.04651
; LINE_WIDTH: 0.880177
G1 F2960.526
G1 X144.735 Y129.708 E.04418
; LINE_WIDTH: 0.820393
G1 F3213.295
G1 X144.659 Y129.951 E.0407
G1 X144.236 Y131.015 E.18292
G1 X143.679 Y131.957 E.17486
G1 X143.049 Y132.761 E.16315
G1 X142.345 Y133.472 E.1599
G1 X141.905 Y133.841 E.09176
G1 X145.981 Y133.841 E.6512
G1 X145.981 Y130.098 E.598
; LINE_WIDTH: 0.840057
G1 F3125.521
G1 X145.961 Y129.844 E.04184
; LINE_WIDTH: 0.880177
G1 F2960.526
G1 X145.941 Y129.59 E.04418
; LINE_WIDTH: 0.920297
G1 F2812.078
G1 X145.921 Y129.336 E.04651
; LINE_WIDTH: 0.960417
G1 F2677.806
G1 X145.901 Y129.082 E.04884
; LINE_WIDTH: 0.995751
G1 F2569.744
G3 X145.893 Y127.464 I71.032 J-1.148 E.32328
; LINE_WIDTH: 1.01507
G1 F2514.261
G1 X145.874 Y126.95 E.10495
; LINE_WIDTH: 1.05336
G1 F2411.097
G1 X145.854 Y126.436 E.10944
; LINE_WIDTH: 1.04895
G1 F2422.562
G1 X145.878 Y126.362 E.01648
; LINE_WIDTH: 1.00182
G1 F2552.044
G1 X145.902 Y126.288 E.01565
; LINE_WIDTH: 0.954701
G1 F2696.149
G1 X145.925 Y126.214 E.01481
; LINE_WIDTH: 0.907578
G1 F2857.501
G1 X145.949 Y126.14 E.01397
; LINE_WIDTH: 0.868012
G1 F3008.685
G1 X145.965 Y125.64 E.08532
; LINE_WIDTH: 0.821073
G1 F3210.177
G2 X145.981 Y122.159 I-148.645 J-2.424 E.55669
G1 X142.025 Y122.159 E.63268
M204 S10000
G1 X144.605 Y124.02 F42000
; LINE_WIDTH: 1.01616
G1 F2511.217
M204 S6000
G3 X145.178 Y125.14 I-8.32 J4.959 E.25746
G2 X145.183 Y122.957 I-349.832 J-1.842 E.44633
G1 X143.846 Y122.957 E.27332
G3 X144.539 Y123.92 I-8.926 J7.159 E.24261
M204 S10000
G1 X145.185 Y130.8 F42000
; LINE_WIDTH: 1.01097
G1 F2525.848
M204 S6000
G1 X144.971 Y131.319 E.11414
G1 X144.359 Y132.369 E.24705
G1 X143.841 Y133.045 E.17321
G1 X145.185 Y133.045 E.27335
G1 X145.185 Y130.92 E.43203
; WIPE_START
G1 X145.185 Y132.92 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.146 Y126.141 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828687
G1 F3175.679
M204 S2000
G1 X140.464 Y124.462 E.38409
G1 X138.314 Y122.704 E.44897
G1 X138.008 Y123.005 E.06941
G1 X142.162 Y127.159 E.94967
G3 X142.247 Y128.246 I-3.428 J.815 E.17696
G1 X137.502 Y123.501 E1.08468
G1 X136.997 Y123.998 E.11454
G1 X142.098 Y129.099 E1.16623
G3 X141.818 Y129.821 I-5.329 J-1.651 E.12529
G1 X139.697 Y127.7 E.4849
G3 X139.64 Y128.645 I-2.592 J.317 E.15385
G1 X141.445 Y130.45 E.41268
G1 X141.001 Y131.008 E.11528
G1 X139.387 Y129.395 E.36887
G3 X139.015 Y130.024 I-6.72 J-3.557 E.11827
G1 X140.499 Y131.508 E.33936
G1 X139.949 Y131.961 E.11507
G1 X138.557 Y130.568 E.31838
G3 X138.039 Y131.052 I-2.814 J-2.489 E.11477
G1 X139.4 Y132.413 E.31109
G1 X138.85 Y132.865 E.11507
G1 X137.473 Y131.488 E.31496
G3 X136.866 Y131.883 I-3.159 J-4.181 E.11714
G1 X138.524 Y133.542 E.37912
; WIPE_START
M204 S6000
G1 X137.11 Y132.127 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.273 Y134.207 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.24434
G1 F2001.495
M204 S6000
G1 X136.133 Y134.207 E.03604
G1 X136.062 Y134.328 E.03604
G1 X136.133 Y134.45 E.03604
G1 X136.273 Y134.45 E.03604
G1 X136.283 Y134.432 E.00526
M204 S10000
G1 X135.296 Y134.44 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.858388
G1 F3000
M204 S6000
G1 X135.016 Y134.495 E.04798
; LINE_WIDTH: 0.821085
G1 X134.723 Y134.551 E.04778
; LINE_WIDTH: 0.774679
G1 X134.578 Y134.576 E.02185
; LINE_WIDTH: 0.726322
G1 X134.434 Y134.601 E.02023
; LINE_WIDTH: 0.677966
G1 X134.29 Y134.626 E.01862
; LINE_WIDTH: 0.629609
G1 X134.146 Y134.651 E.01701
; LINE_WIDTH: 0.581252
G1 X134.002 Y134.676 E.01539
; LINE_WIDTH: 0.532896
G1 X133.858 Y134.7 E.01378
; LINE_WIDTH: 0.484539
G1 X133.713 Y134.725 E.01216
; LINE_WIDTH: 0.436183
G1 X133.569 Y134.75 E.01055
; LINE_WIDTH: 0.387826
G1 X133.425 Y134.775 E.00893
; LINE_WIDTH: 0.33947
M73 P55 R7
G1 X133.281 Y134.8 E.00732
; LINE_WIDTH: 0.291113
G1 X133.137 Y134.825 E.00571
; LINE_WIDTH: 0.242756
G1 X132.992 Y134.85 E.00409
; WIPE_START
G1 X133.137 Y134.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.144 Y128.162 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X131.146 Y128.02 E.02203
M204 S10000
G1 X130.997 Y128.654 F42000
; LINE_WIDTH: 1.09073
G1 F2318.273
M204 S6000
G1 X129.862 Y130.107 E.40835
G1 X130.997 Y131.213 E.35103
G1 X130.997 Y128.774 E.54007
M204 S10000
G1 X130.998 Y124.803 F42000
; LINE_WIDTH: 1.08962
G1 F2320.928
M204 S6000
G1 X129.863 Y125.913 E.35118
G1 X130.998 Y127.354 E.40571
G1 X130.998 Y124.923 E.5378
; WIPE_START
G1 X130.998 Y126.923 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.992 Y121.15 Z5.28 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242724
G1 F3000
M204 S6000
G1 X133.136 Y121.175 E.00409
; LINE_WIDTH: 0.291017
G1 X133.28 Y121.2 E.0057
; LINE_WIDTH: 0.33931
G1 X133.424 Y121.225 E.00731
; LINE_WIDTH: 0.387603
G1 X133.568 Y121.25 E.00892
; LINE_WIDTH: 0.435896
G1 X133.712 Y121.275 E.01053
; LINE_WIDTH: 0.484189
G1 X133.856 Y121.299 E.01214
; LINE_WIDTH: 0.532482
G1 X134 Y121.324 E.01375
; LINE_WIDTH: 0.580775
G1 X134.144 Y121.349 E.01536
; LINE_WIDTH: 0.629069
G1 X134.288 Y121.374 E.01697
; LINE_WIDTH: 0.677362
G1 X134.432 Y121.399 E.01858
; LINE_WIDTH: 0.725655
G1 X134.577 Y121.424 E.02019
; LINE_WIDTH: 0.773948
G1 X134.721 Y121.448 E.0218
; LINE_WIDTH: 0.820488
G1 X135.015 Y121.505 E.0479
; LINE_WIDTH: 0.858169
G1 X135.296 Y121.559 E.04814
M204 S10000
G1 X136.277 Y121.553 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25246
G1 F1987.141
M204 S6000
G1 X136.135 Y121.553 E.03656
G1 X136.065 Y121.676 E.03656
G1 X136.135 Y121.798 E.03656
G1 X136.277 Y121.798 E.03656
G1 X136.288 Y121.78 E.00556
; WIPE_START
G1 X136.277 Y121.798 E-.02784
G1 X136.135 Y121.798 E-.18304
G1 X136.065 Y121.676 E-.18304
G1 X136.135 Y121.553 E-.18305
G1 X136.277 Y121.553 E-.18303
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.645 Y121.529 Z5.28 F42000
G1 X112.209 Y121.479 Z5.28
G1 Z4.88
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I6.46 J7.233 E.44654
G1 X122.192 Y135.388 E2.65865
G3 X119.605 Y136.395 I-4.66 J-8.147 E.44486
G1 X129.367 Y126.633 E2.20441
G1 X130.446 Y128.003 E.27848
G1 X129.374 Y129.374 E.27794
G1 X119.598 Y119.598 E2.20756
G3 X122.192 Y120.612 I-2.173 J9.383 E.4462
G1 X110.418 Y132.386 E2.65865
G2 X112.209 Y134.521 I8.25 J-5.097 E.44654
; CHANGE_LAYER
; Z_HEIGHT: 5.44
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.494 Y133.833 E-.37708
G1 X111.036 Y133.29 E-.27005
G1 X110.868 Y133.045 E-.11288
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 10/51
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z5.44 I.747 J1.531 P1  F42000
G1 X132.35 Y122.563 Z5.44
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.35 Y121.64 E.14733
G1 X134.146 Y122.143 E.29774
G3 X138.143 Y123.737 I-5.933 J20.685 E.68831
G1 X140.039 Y121.916 E.41978
G1 X142.577 Y124.011 E.52549
G3 X143.822 Y125.467 I-4.652 J5.239 E.30684
G3 X144.461 Y129.001 I-3.929 J2.536 E.58853
G3 X143.152 Y131.423 I-5.37 J-1.338 E.44426
G1 X142.616 Y131.955 E.12065
G1 X139.997 Y134.108 E.54127
G1 X138.134 Y132.268 E.41817
G3 X135.984 Y133.24 I-9.029 J-17.102 E.37684
G3 X132.35 Y134.36 I-13.054 J-35.907 E.60747
G1 X132.35 Y122.683 E1.86461
M204 S250
G1 X133.05 Y122.563 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X134.866 Y123.104 I-7.362 J28.016 E.30263
G3 X138.522 Y124.768 I-5.307 J16.503 E.6428
G3 X140.263 Y126.333 I-3.367 J5.5 E.37592
G3 X140.721 Y128.773 I-2.172 J1.67 E.41147
G3 X139.548 Y130.459 I-3.821 J-1.408 E.33146
G3 X137.27 Y131.928 I-7.008 J-8.363 E.43399
G3 X133.05 Y133.437 I-10.333 J-22.24 E.71653
G1 X133.05 Y122.683 E1.71725
; WIPE_START
M204 S6000
G1 X133.946 Y122.814 E-.34411
G1 X134.866 Y123.104 E-.36659
G1 X134.988 Y123.147 E-.04929
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.427 Y121.215 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X133.097 Y121.122 E.05481
G1 X133.147 Y120.76 E.05846
G1 X147.38 Y120.76 E2.27275
G1 X147.38 Y135.24 E2.31222
G1 X133.147 Y135.24 E2.27268
G1 X133.097 Y134.878 E.05846
G2 X138.009 Y133.129 I-6.539 J-26.145 E.83385
G1 X139.955 Y135.049 E.43644
G1 X143.086 Y132.475 E.64723
G1 X143.67 Y131.895 E.13148
G2 X145.144 Y129.156 I-4.546 J-4.212 E.50198
G2 X144.416 Y125.098 I-5.254 J-1.152 E.67555
G2 X143.042 Y123.488 I-6.515 J4.171 E.33909
G1 X140.004 Y120.979 E.62913
G1 X138.02 Y122.885 E.43923
G2 X134.346 Y121.472 I-10.11 J20.812 E.62936
G1 X133.543 Y121.247 E.13309
; WIPE_START
G1 X133.097 Y121.122 E-.17604
G1 X133.147 Y120.76 E-.13913
G1 X134.317 Y120.76 E-.44483
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.65 Y120.76 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.65 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.29787
G3 X121.615 Y136.363 I-8.313 J-11.946 E.35368
G3 X118.212 Y118.823 I-3.808 J-8.361 E5.30044
G3 X122.583 Y120.15 I-.39 J9.146 E.73718
G1 X123.522 Y120.76 E.17886
G1 X131.53 Y120.76 E1.27871
; WIPE_START
G1 X131.547 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.08 Y121.53 Z5.84 F42000
G1 X148.08 Y120.06 Z5.84
G1 Z5.44
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.729 Y135.94 E3.88821
G3 X120.236 Y137.586 I-6.32 J-8.882 E.61982
G3 X118.24 Y118.124 I-2.431 J-9.584 E5.42155
G3 X122.946 Y119.552 I-.417 J9.844 E.79363
G1 X123.729 Y120.06 E.14906
G1 X147.96 Y120.06 E3.86905
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96687
G3 X118.269 Y117.425 I-6.127 J-8.637 E6.42837
G3 X123.937 Y119.36 I-.48 J10.672 E.96921
G1 X148.66 Y119.36 E3.94771
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.84 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.84
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z5.84 F4000
            G39.3 S1
            G0 Z5.84 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X143.631 Y122.159 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G3 X145.276 Y123.866 I-6.631 J8.037 E.37937
G1 X145.841 Y124.76 E.16886
G1 X145.981 Y125.057 E.05231
G1 X145.981 Y122.159 E.46264
G1 X143.751 Y122.159 E.35603
M204 S10000
G1 X145.346 Y122.764 F42000
; LINE_WIDTH: 0.770897
G1 F3457.708
M204 S6000
G2 X145.307 Y122.905 I-.041 J.065 E.04227
M204 S10000
G1 X145.348 Y133.097 F42000
; LINE_WIDTH: 0.767657
G1 F3475.011
M204 S6000
G2 X145.308 Y133.237 I-.04 J.064 E.04175
M204 S10000
G1 X143.628 Y133.841 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X145.981 Y133.841 E.37562
G1 X145.981 Y130.96 E.4599
M73 P56 R7
G1 X145.395 Y131.969 E.18627
G1 X144.782 Y132.745 E.1578
G1 X144.061 Y133.479 E.16445
G1 X143.72 Y133.764 E.07079
M204 S10000
G1 X141.675 Y134.541 F42000
; LINE_WIDTH: 0.822873
G1 F3201.954
M204 S6000
G1 X146.681 Y134.541 E.80249
G1 X146.681 Y129.381 E.82716
G3 X146.664 Y127.114 I702.887 J-6.361 E.36352
G1 X146.681 Y126.008 E.1774
G1 X146.681 Y121.459 E.72926
G1 X141.685 Y121.459 E.80101
G1 X143.499 Y122.958 E.3773
G1 X144.143 Y123.588 E.14447
G1 X144.734 Y124.309 E.14943
G1 X145.246 Y125.129 E.15504
G1 X145.654 Y126.071 E.1645
G1 X145.928 Y127.103 E.17117
G3 X145.942 Y128.776 I-9.099 J.911 E.26862
G3 X145.305 Y130.763 I-7.553 J-1.324 E.33562
G1 X144.797 Y131.605 E.15773
G1 X144.237 Y132.306 E.14378
G1 X143.543 Y133.005 E.15795
G1 X141.768 Y134.464 E.36841
; WIPE_START
G1 X143.313 Y133.194 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.997 Y134.207 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 1.24368
G1 F2002.67
M204 S6000
G1 X137.857 Y134.207 E.036
G1 X137.786 Y134.329 E.036
G1 X137.857 Y134.45 E.036
G1 X137.997 Y134.45 E.036
G1 X138.007 Y134.433 E.00524
M204 S10000
G1 X137.02 Y134.44 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.860862
G1 F3000
M204 S6000
G1 X136.753 Y134.492 E.0459
; LINE_WIDTH: 0.828562
G1 X136.473 Y134.546 E.0462
; LINE_WIDTH: 0.784346
G1 X136.332 Y134.571 E.0216
; LINE_WIDTH: 0.735764
G1 X136.192 Y134.595 E.02002
; LINE_WIDTH: 0.687182
G1 X136.051 Y134.619 E.01844
; LINE_WIDTH: 0.6386
G1 X135.911 Y134.643 E.01686
; LINE_WIDTH: 0.590018
G1 X135.77 Y134.668 E.01528
; LINE_WIDTH: 0.541437
G1 X135.63 Y134.692 E.0137
; LINE_WIDTH: 0.492855
G1 X135.489 Y134.716 E.01212
; LINE_WIDTH: 0.46752
G1 X135.483 Y134.717 E.00051
; LINE_WIDTH: 0.441704
G1 X135.312 Y134.744 E.01266
; LINE_WIDTH: 0.392117
G1 X135.142 Y134.77 E.0107
; LINE_WIDTH: 0.342531
G1 X134.971 Y134.796 E.00875
; LINE_WIDTH: 0.292944
G1 X134.801 Y134.822 E.0068
; LINE_WIDTH: 0.243358
G1 X134.63 Y134.849 E.00485
; WIPE_START
G1 X134.801 Y134.822 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.496 Y131.158 Z5.84 F42000
G1 X143.868 Y129.859 Z5.84
G1 Z5.44
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828037
G1 F3178.595
M204 S2000
G1 X142.202 Y131.525 E.38053
G1 X140.034 Y133.308 E.45345
G1 X139.724 Y133.002 E.0703
G1 X143.886 Y128.84 E.95067
G2 X143.972 Y127.754 I-3.344 J-.81 E.1768
G1 X139.22 Y132.505 E1.08531
G1 X138.716 Y132.008 E.11433
G1 X143.82 Y126.904 E1.16579
G2 X143.54 Y126.183 I-4.274 J1.247 E.12507
G1 X141.419 Y128.304 E.48437
G2 X141.365 Y127.357 I-2.883 J-.308 E.1538
G1 X143.168 Y125.555 E.41177
G2 X142.724 Y124.997 I-6.085 J4.386 E.11511
G1 X141.112 Y126.609 E.36827
G2 X140.741 Y125.979 I-8.196 J4.386 E.11817
G1 X142.223 Y124.497 E.33848
G2 X141.678 Y124.041 I-3.396 J3.508 E.11488
G1 X140.285 Y125.434 E.31829
G2 X139.767 Y124.951 I-3.886 J3.643 E.11448
G1 X141.13 Y123.588 E.31132
G1 X140.582 Y123.135 E.11484
G1 X138.975 Y124.742 E.36697
; WIPE_START
M204 S6000
G1 X140.389 Y123.328 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.008 Y121.559 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.26846
G1 F1959.452
M204 S6000
G1 X137.865 Y121.559 E.0376
G1 X137.793 Y121.684 E.0376
G1 X137.865 Y121.808 E.0376
G1 X138.008 Y121.808 E.0376
G1 X138.02 Y121.788 E.00616
M204 S10000
G1 X137.019 Y121.56 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.859496
G1 F3000
M204 S6000
G1 X136.746 Y121.507 E.04699
; LINE_WIDTH: 0.824574
G1 X136.459 Y121.451 E.04703
; LINE_WIDTH: 0.77933
G1 X136.319 Y121.427 E.02132
; LINE_WIDTH: 0.731088
G1 X136.179 Y121.403 E.01976
; LINE_WIDTH: 0.682846
G1 X136.04 Y121.379 E.0182
; LINE_WIDTH: 0.634604
G1 X135.9 Y121.355 E.01664
; LINE_WIDTH: 0.586362
G1 X135.76 Y121.331 E.01508
; LINE_WIDTH: 0.53812
G1 X135.62 Y121.306 E.01352
; LINE_WIDTH: 0.489878
G1 X135.481 Y121.282 E.01196
; LINE_WIDTH: 0.464735
G1 X135.475 Y121.281 E.0005
; LINE_WIDTH: 0.439195
G1 X135.306 Y121.255 E.01243
; LINE_WIDTH: 0.390168
G1 X135.137 Y121.229 E.01052
; LINE_WIDTH: 0.341142
G1 X134.968 Y121.203 E.00861
; LINE_WIDTH: 0.292116
G1 X134.799 Y121.177 E.0067
; LINE_WIDTH: 0.24309
G1 X134.63 Y121.151 E.00479
; WIPE_START
G1 X134.799 Y121.177 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.227 Y125.058 Z5.84 F42000
G1 X112.216 Y134.513 Z5.84
G1 Z5.44
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.056 J-6.94 E.44641
G1 X122.192 Y120.612 E2.65865
G2 X119.598 Y119.598 I-4.766 J8.369 E.44621
G1 X131.056 Y131.056 E2.58722
G1 X131.056 Y124.944 E.97582
G1 X119.598 Y136.402 E2.58723
G2 X122.192 Y135.388 I-2.173 J-9.385 E.44621
G1 X110.418 Y123.614 E2.65864
G3 X112.216 Y121.487 I7.481 J4.498 E.44671
; CHANGE_LAYER
; Z_HEIGHT: 6
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.494 Y122.166 E-.37667
G1 X111.025 Y122.725 E-.27736
G1 X110.868 Y122.955 E-.10598
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 11/51
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z6 I.067 J1.702 P1  F42000
G1 X132.168 Y122.112 Z6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.168 Y121.242 E.13891
G3 X135.896 Y122.151 I-9.207 J45.855 E.61275
G3 X139.518 Y123.556 I-6.509 J22.152 E.62114
G1 X139.869 Y123.738 E.06308
G1 X141.719 Y121.915 E.41477
G1 X144.283 Y123.995 E.52724
G3 X145.322 Y125.129 I-5.338 J5.939 E.246
G3 X146.191 Y128.973 I-3.797 J2.878 E.64879
G3 X144.868 Y131.431 I-5.344 J-1.291 E.45053
G1 X144.333 Y131.961 E.12031
G1 X141.733 Y134.096 E.53717
G1 X139.864 Y132.264 E.41792
G3 X136.851 Y133.546 I-9.587 J-18.341 E.5234
G3 X132.168 Y134.758 I-12.794 J-39.781 E.77271
G1 X132.168 Y122.232 E2.00018
M204 S250
G1 X132.868 Y122.112 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X137.277 Y123.348 I-6.688 J32.336 E.73163
G3 X140.772 Y125.132 I-4.713 J13.543 E.62859
G3 X142.114 Y126.527 I-3.194 J4.416 E.3107
G3 X142.255 Y129.229 I-2.248 J1.473 E.4528
G3 X140.8 Y130.847 I-4.416 J-2.511 E.35013
G3 X138.276 Y132.256 I-7.379 J-10.245 E.4626
G3 X132.868 Y133.888 I-11.14 J-27.141 E.90336
G1 X132.868 Y122.232 E1.86125
; WIPE_START
M204 S6000
G1 X133.696 Y122.293 E-.31528
G1 X134.655 Y122.531 E-.37565
G1 X134.83 Y122.58 E-.06908
; WIPE_END
M73 P57 R7
G1 E-.04 F1800
M204 S10000
G1 X136.056 Y130.113 Z6.4 F42000
G1 X136.74 Y134.316 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X137.073 Y134.209 E.05594
G2 X139.742 Y133.125 I-8.465 J-24.664 E.46017
G1 X141.692 Y135.035 E.43589
G1 X144.802 Y132.481 E.64265
G1 X145.386 Y131.903 E.13119
G2 X146.874 Y129.128 I-4.554 J-4.228 E.50822
G2 X146.977 Y128.416 I-3.121 J-.817 E.11519
G1 X147.38 Y128.432 E.06444
G1 X147.38 Y135.24 E1.08715
G1 X134.86 Y135.24 E1.99914
G1 X134.815 Y134.871 E.05936
G2 X136.112 Y134.518 I-6.207 J-25.327 E.21461
G1 X136.626 Y134.353 E.08616
; WIPE_START
G1 X137.073 Y134.209 E-.17873
G1 X137.989 Y133.882 E-.36954
G1 X138.506 Y133.673 E-.21173
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.829 Y127.383 Z6.4 F42000
G1 X147.38 Y120.76 Z6.4
G1 Z6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y127.598 E1.09186
G1 X146.982 Y127.618 E.0637
G2 X145.654 Y124.419 I-5.691 J.487 E.562
G2 X144.746 Y123.47 I-6.86 J5.657 E.20989
G1 X141.673 Y120.977 E.63178
G1 X139.74 Y122.882 E.43355
G2 X134.815 Y121.129 I-10.938 J22.92 E.83615
G1 X134.86 Y120.76 E.05936
G1 X147.26 Y120.76 E1.97999
; WIPE_START
G1 X147.295 Y122.759 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.723 Y121.803 Z6.4 F42000
G1 X131.469 Y120.76 Z6.4
G1 Z6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.469 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.26883
G3 X121.616 Y136.362 I-8.472 J-12.215 E.35343
G3 X118.182 Y118.822 I-3.81 J-8.36 E5.29605
G3 X122.584 Y120.151 I-.36 J9.147 E.74209
G1 X123.522 Y120.76 E.17861
G1 X131.349 Y120.76 E1.24967
; WIPE_START
G1 X131.365 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.9 Y121.543 Z6.4 F42000
G1 X148.08 Y120.06 Z6.4
G1 Z6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E2.5357
G1 X123.729 Y135.94 E3.88821
G3 X120.238 Y137.586 I-6.32 J-8.883 E.61958
G3 X118.211 Y118.123 I-2.432 J-9.584 E5.41711
G3 X122.948 Y119.553 I-.388 J9.844 E.79855
G1 X123.729 Y120.06 E.1488
G1 X147.96 Y120.06 E3.86905
; WIPE_START
G1 X147.975 Y122.06 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96687
G3 X118.24 Y117.423 I-6.127 J-8.636 E6.4237
G3 X123.937 Y119.36 I-.461 J10.7 E.97378
G1 X148.66 Y119.36 E3.94771
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z6.4 F4000
            G39.3 S1
            G0 Z6.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X146.7 Y124.499 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.261261
G1 F3000
M204 S6000
G3 X146.99 Y125.926 I-40.812 J9.036 E.0469
M204 S10000
G1 X147.012 Y125.922 F42000
; LINE_WIDTH: 0.508188
G1 F3000
M204 S6000
G1 X146.664 Y124.511 E.12866
; WIPE_START
G1 X147.012 Y125.922 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.587 Y126.134 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828107
G1 F3178.28
M204 S2000
G2 X143.889 Y124.442 I-39.051 J37.506 E.38723
G1 X141.757 Y122.712 E.44347
G1 X141.459 Y123.006 E.0677
G1 X145.611 Y127.158 E.9485
G3 X145.692 Y128.241 I-3.523 J.809 E.17603
G1 X140.954 Y123.503 E1.08228
G1 X140.45 Y124 E.11435
G1 X145.544 Y129.094 E1.16368
G3 X145.265 Y129.816 I-4.128 J-1.179 E.12522
G1 X143.141 Y127.692 E.48524
G3 X143.089 Y128.641 I-4.07 J.254 E.15392
G1 X144.893 Y130.445 E.41207
G3 X144.45 Y131.003 I-7.431 J-5.453 E.11512
G1 X142.835 Y129.389 E.36877
G3 X142.466 Y130.02 I-6.775 J-3.542 E.11824
G1 X143.949 Y131.504 E.33888
G1 X143.401 Y131.957 E.11487
G1 X142.009 Y130.564 E.31808
G3 X141.491 Y131.048 I-2.826 J-2.502 E.11458
M73 P58 R7
G1 X142.851 Y132.408 E.31064
G1 X142.301 Y132.859 E.1149
G1 X140.7 Y131.257 E.36593
; WIPE_START
M204 S6000
G1 X142.114 Y132.672 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.726 Y134.201 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25408
M73 P58 R6
G1 F1984.302
M204 S6000
G1 X139.585 Y134.201 E.03667
G1 X139.514 Y134.324 E.03667
G1 X139.585 Y134.446 E.03667
G1 X139.726 Y134.446 E.03667
G1 X139.737 Y134.427 E.00562
M204 S10000
G1 X138.744 Y134.44 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.852243
G1 F3000
M204 S6000
G1 X138.248 Y134.537 E.08444
; LINE_WIDTH: 0.82535
G1 X138.234 Y134.539 E.00232
; LINE_WIDTH: 0.798231
G1 X138.093 Y134.564 E.02216
; LINE_WIDTH: 0.749219
G1 X137.952 Y134.588 E.02055
; LINE_WIDTH: 0.700207
G1 X137.81 Y134.613 E.01895
; LINE_WIDTH: 0.651195
G1 X137.669 Y134.637 E.01735
; LINE_WIDTH: 0.602182
G1 X137.528 Y134.662 E.01575
; LINE_WIDTH: 0.55317
G1 X137.387 Y134.686 E.01415
; LINE_WIDTH: 0.504158
G1 X137.246 Y134.711 E.01255
; LINE_WIDTH: 0.47856
G1 X137.239 Y134.712 E.00055
; LINE_WIDTH: 0.455901
G1 X137.092 Y134.735 E.01143
; LINE_WIDTH: 0.412749
G1 X136.945 Y134.757 E.00996
; LINE_WIDTH: 0.369597
G1 X136.797 Y134.78 E.00849
; LINE_WIDTH: 0.326446
G1 X136.65 Y134.803 E.00702
; LINE_WIDTH: 0.283294
G1 X136.502 Y134.826 E.00555
; LINE_WIDTH: 0.240142
G1 X136.355 Y134.849 E.00408
; WIPE_START
G1 X136.502 Y134.826 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.49 Y135.098 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.99625
G1 F2568.278
M204 S6000
G1 X134.029 Y135.154 E.0928
; LINE_WIDTH: 0.967986
G1 F2653.898
G1 X133.784 Y135.181 E.0478
; LINE_WIDTH: 0.920005
G1 F2813.104
G1 X133.538 Y135.208 E.04509
; LINE_WIDTH: 0.872024
G1 F2992.63
G1 X133.293 Y135.234 E.04239
; LINE_WIDTH: 0.824043
G1 F3000
G1 X133.047 Y135.261 E.03968
; LINE_WIDTH: 0.776062
G1 X132.801 Y135.288 E.03698
; LINE_WIDTH: 0.728081
G1 X132.556 Y135.314 E.03427
; LINE_WIDTH: 0.6801
G1 X132.31 Y135.341 E.03157
; LINE_WIDTH: 0.632119
G1 X132.064 Y135.368 E.02886
; LINE_WIDTH: 0.584137
G1 X131.819 Y135.394 E.02616
; WIPE_START
G1 X132.064 Y135.368 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.676 Y134.812 Z6.4 F42000
G1 X143.397 Y134.541 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X146.681 Y134.541 E.52432
G1 X146.681 Y132.214 E.37157
G1 X146.158 Y132.061 E.08693
G1 X145.892 Y132.386 E.06712
G3 X145.259 Y133.011 I-7.003 J-6.46 E.14213
G1 X143.49 Y134.464 E.36559
M204 S10000
G1 X145.879 Y133.563 F42000
; LINE_WIDTH: 1.15152
G1 F2181.628
M204 S6000
G1 X145.751 Y133.563 E.03033
G1 X145.686 Y133.675 E.03034
G1 X145.751 Y133.787 E.03033
G1 X145.884 Y133.779 E.03143
M204 S10000
G1 X146.669 Y131.489 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.472025
G1 F3000
M204 S6000
G1 X147.011 Y130.076 E.11671
M204 S10000
G1 X146.99 Y130.072 F42000
; LINE_WIDTH: 0.238699
G1 F3000
M204 S6000
G3 X146.708 Y131.503 I-69.139 J-12.89 E.03943
M204 S10000
G1 X146.643 Y131.48 F42000
; LINE_WIDTH: 0.710234
G1 F3000
M204 S6000
G2 X147.03 Y130.108 I-77.984 J-22.76 E.19191
; WIPE_START
G1 X146.643 Y131.48 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.946 Y128.017 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.233452
G1 F3000
M204 S6000
G1 X147.338 Y128.015 E.01014
; LINE_WIDTH: 0.263187
G1 X147.73 Y128.013 E.0128
; WIPE_START
G1 X147.338 Y128.015 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.392 Y121.482 Z6.4 F42000
G1 X143.379 Y121.459 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X145.199 Y122.937 E.37431
G1 X145.855 Y123.576 E.14619
G1 X146.14 Y123.92 E.07133
G1 X146.681 Y123.786 E.08894
G1 X146.681 Y121.459 E.37151
G1 X143.499 Y121.459 E.50801
M204 S10000
G1 X145.879 Y122.214 F42000
; LINE_WIDTH: 1.15224
G1 F2180.106
M204 S6000
G1 X145.75 Y122.214 E.03038
G1 X145.686 Y122.325 E.03038
G1 X145.75 Y122.437 E.03038
G1 X145.884 Y122.429 E.03149
; WIPE_START
G1 X145.75 Y122.437 E-.19517
G1 X145.686 Y122.325 E-.18828
G1 X145.75 Y122.214 E-.18828
G1 X145.879 Y122.214 E-.18827
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.726 Y121.554 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 1.25562
G1 F1981.611
M204 S6000
G1 X139.584 Y121.554 E.03677
G1 X139.513 Y121.677 E.03677
G1 X139.584 Y121.8 E.03677
G1 X139.726 Y121.8 E.03677
G1 X139.737 Y121.781 E.00568
M204 S10000
G1 X138.743 Y121.56 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.861311
G1 F3000
M204 S6000
G1 X138.48 Y121.509 E.04541
; LINE_WIDTH: 0.830223
G1 X138.202 Y121.455 E.04578
; LINE_WIDTH: 0.786744
G1 X138.062 Y121.431 E.02155
; LINE_WIDTH: 0.738401
G1 X137.923 Y121.407 E.01999
; LINE_WIDTH: 0.690059
G1 X137.783 Y121.382 E.01842
; LINE_WIDTH: 0.641716
G1 X137.644 Y121.358 E.01686
; LINE_WIDTH: 0.593373
G1 X137.504 Y121.334 E.0153
; LINE_WIDTH: 0.545031
G1 X137.364 Y121.31 E.01374
; LINE_WIDTH: 0.496688
G1 X137.225 Y121.286 E.01217
; LINE_WIDTH: 0.471479
G1 X137.218 Y121.285 E.00052
; LINE_WIDTH: 0.44944
G1 X137.074 Y121.262 E.01094
; LINE_WIDTH: 0.407465
G1 X136.93 Y121.24 E.00955
; LINE_WIDTH: 0.36549
G1 X136.787 Y121.218 E.00815
; LINE_WIDTH: 0.323515
G1 X136.643 Y121.196 E.00676
; LINE_WIDTH: 0.28154
G1 X136.499 Y121.173 E.00536
; LINE_WIDTH: 0.239565
G1 X136.355 Y121.151 E.00397
; WIPE_START
G1 X136.499 Y121.173 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.49 Y120.902 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.995991
G1 F2569.039
M204 S6000
G1 X134.027 Y120.845 E.09318
; LINE_WIDTH: 0.967541
G1 F2655.293
G1 X133.782 Y120.819 E.04773
; LINE_WIDTH: 0.919635
G1 F2814.407
G1 X133.537 Y120.792 E.04503
; LINE_WIDTH: 0.871728
G1 F2993.807
G1 X133.291 Y120.766 E.04233
; LINE_WIDTH: 0.823822
G1 F3000
G1 X133.046 Y120.739 E.03964
; LINE_WIDTH: 0.775916
G1 X132.8 Y120.712 E.03694
; LINE_WIDTH: 0.728009
G1 X132.555 Y120.686 E.03424
; LINE_WIDTH: 0.680103
G1 X132.309 Y120.659 E.03154
; LINE_WIDTH: 0.632197
G1 X132.064 Y120.633 E.02884
; LINE_WIDTH: 0.58429
G1 X131.819 Y120.606 E.02614
; WIPE_START
G1 X132.064 Y120.633 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.439 Y120.96 Z6.4 F42000
G1 X112.216 Y121.486 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I5.755 J6.683 E.44669
G1 X122.192 Y135.388 E2.65864
G3 X119.598 Y136.402 I-4.766 J-8.368 E.44621
G1 X130.874 Y125.126 E2.54614
G1 X130.874 Y130.874 E.91771
G1 X119.598 Y119.598 E2.54614
G3 X122.192 Y120.612 I-2.173 J9.383 E.44621
G1 X110.418 Y132.386 E2.65864
G2 X112.215 Y134.514 I7.879 J-4.831 E.44641
; CHANGE_LAYER
; Z_HEIGHT: 6.56
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.154 Y133.444 E-.57253
G1 X110.873 Y133.039 E-.18748
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 12/51
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z6.56 I.784 J1.513 P1  F42000
G1 X132.686 Y121.742 Z6.56
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X138.351 Y123.117 I-6.96 J41.034 E.93157
G3 X141.955 Y124.76 I-5.325 J16.455 E.63389
G3 X143.69 Y126.304 I-3.326 J5.481 E.37285
G3 X143.713 Y129.665 I-2.144 J1.695 E.57794
G3 X141.992 Y131.216 I-5.081 J-3.905 E.372
G3 X138.383 Y132.872 I-8.901 J-14.641 E.63556
G3 X132.686 Y134.258 I-12.649 J-39.591 E.93687
G1 X132.686 Y121.862 E1.97938
; WIPE_START
M204 S6000
G1 X134.385 Y122.066 E-.65021
G1 X134.667 Y122.129 E-.10979
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.774 Y129.68 Z6.96 F42000
G1 X136.535 Y134.877 Z6.96
G1 Z6.56
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G2 X141.467 Y133.123 I-6.373 J-25.734 E.83714
G1 X143.415 Y135.033 E.43555
G1 X146.519 Y132.487 E.641
G1 X147.38 Y131.636 E.1933
G1 X147.38 Y135.24 E.57548
G1 X136.585 Y135.24 E1.72379
G1 X136.552 Y134.996 E.0394
; WIPE_START
G1 X137.885 Y134.5 E-.54055
G1 X138.435 Y134.325 E-.21945
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.637 Y127.953 Z6.96 F42000
G1 X147.38 Y120.76 Z6.96
G1 Z6.56
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y124.368 E.5762
G2 X146.457 Y123.459 I-18.924 J18.292 E.20696
G1 X143.392 Y120.981 E.62927
G1 X141.465 Y122.884 E.43237
G2 X136.533 Y121.128 I-10.892 J22.798 E.83739
G1 X136.579 Y120.76 E.05931
G1 X147.26 Y120.76 E1.70558
; WIPE_START
G1 X147.327 Y122.759 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.753 Y121.815 Z6.96 F42000
G1 X131.287 Y120.76 Z6.96
G1 Z6.56
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.287 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.23979
G3 X121.618 Y136.361 I-8.639 J-12.498 E.35312
G3 X118.153 Y118.821 I-3.812 J-8.36 E5.29172
G3 X122.585 Y120.152 I-.331 J9.15 E.74707
G1 X123.522 Y120.76 E.17832
G1 X131.167 Y120.76 E1.22063
; WIPE_START
M73 P59 R6
G1 X131.183 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.72 Y121.555 Z6.96 F42000
G1 X148.08 Y120.06 Z6.96
G1 Z6.56
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y126.356 E1.00536
G1 X147.738 Y126.42 E.05566
G2 X146.348 Y124.323 I-5.528 J2.153 E.40471
G1 X145.994 Y123.985 E.07822
G1 X143.439 Y121.919 E.52473
G1 X141.595 Y123.739 E.41376
G2 X137.647 Y122.159 I-9.896 J19.003 E.68016
G2 X134.526 Y121.381 I-11.628 J39.99 E.51373
G1 X131.986 Y120.896 E.4128
G1 X131.986 Y135.105 E2.2688
G1 X134.534 Y134.617 E.41421
G2 X140.297 Y132.89 I-5.981 J-30.437 E.96217
G2 X141.589 Y132.263 I-5.472 J-12.907 E.2294
G1 X143.457 Y134.094 E.41759
G1 X146.05 Y131.966 E.53561
G2 X147.748 Y129.573 I-4.169 J-4.755 E.47278
G1 X148.08 Y129.644 E.05428
G1 X148.08 Y135.94 E1.00535
G1 X123.729 Y135.94 E3.88822
G3 X120.239 Y137.585 I-6.32 J-8.883 E.61937
G3 X118.182 Y118.121 I-2.433 J-9.584 E5.41264
G3 X122.949 Y119.553 I-.359 J9.847 E.80348
G1 X123.729 Y120.06 E.14852
G1 X147.96 Y120.06 E3.86906
; WIPE_START
G1 X147.998 Y122.059 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96688
G3 X118.211 Y117.422 I-6.127 J-8.637 E6.41905
G3 X123.937 Y119.36 I-.431 J10.701 E.97843
G1 X148.66 Y119.36 E3.94771
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.96 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.96
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z6.96 F4000
            G39.3 S1
            G0 Z6.96 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X145.187 Y121.491 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.883817
G1 F2946.415
M204 S6000
G1 X146.649 Y122.673 E.32744
G1 X146.649 Y121.491 E.20586
G1 X145.307 Y121.491 E.23373
; WIPE_START
G1 X146.649 Y121.491 E-.50975
G1 X146.649 Y122.15 E-.25025
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.451 Y121.555 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 1.25698
G1 F1979.24
M204 S6000
G1 X141.308 Y121.555 E.03686
G1 X141.237 Y121.678 E.03686
G1 X141.308 Y121.801 E.03686
G1 X141.451 Y121.801 E.03686
G1 X141.462 Y121.782 E.00573
M204 S10000
G1 X140.467 Y121.56 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.862067
G1 F3000
M204 S6000
G1 X140.208 Y121.509 E.04468
; LINE_WIDTH: 0.832685
G1 X139.935 Y121.457 E.04521
; LINE_WIDTH: 0.790291
G1 X139.797 Y121.433 E.02137
; LINE_WIDTH: 0.74255
G1 X139.659 Y121.409 E.01984
; LINE_WIDTH: 0.69481
G1 X139.522 Y121.385 E.01832
; LINE_WIDTH: 0.647069
G1 X139.384 Y121.361 E.0168
; LINE_WIDTH: 0.599329
G1 X139.246 Y121.337 E.01528
; LINE_WIDTH: 0.551588
G1 X139.109 Y121.313 E.01375
; LINE_WIDTH: 0.50273
G1 X138.965 Y121.288 E.01277
; LINE_WIDTH: 0.456249
G1 X138.817 Y121.265 E.01145
; LINE_WIDTH: 0.413036
G1 X138.669 Y121.243 E.00998
; LINE_WIDTH: 0.369823
G1 X138.522 Y121.22 E.00851
; LINE_WIDTH: 0.32661
G1 X138.374 Y121.197 E.00703
; LINE_WIDTH: 0.283397
G1 X138.227 Y121.174 E.00556
; LINE_WIDTH: 0.240184
G1 X138.079 Y121.151 E.00409
; WIPE_START
G1 X138.227 Y121.174 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.149 Y121.387 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.946153
G1 F2724.049
M204 S6000
G1 X135.791 Y120.873 E.11803
; LINE_WIDTH: 0.976816
M73 P60 R6
G1 F2626.543
G1 X135.773 Y120.848 E.00591
; LINE_WIDTH: 0.973031
G1 F2638.202
G1 X135.552 Y120.824 E.04341
; LINE_WIDTH: 0.924805
G1 F2796.322
G1 X135.33 Y120.8 E.04095
; LINE_WIDTH: 0.87658
G1 F2974.604
G1 X135.108 Y120.776 E.0385
; LINE_WIDTH: 0.828355
G1 F3000
G1 X134.886 Y120.752 E.03604
; LINE_WIDTH: 0.78013
G1 X134.665 Y120.728 E.03359
; LINE_WIDTH: 0.755137
G1 X134.656 Y120.727 E.00129
; LINE_WIDTH: 0.729877
G1 X134.394 Y120.702 E.03656
; LINE_WIDTH: 0.681181
G1 X134.133 Y120.677 E.03363
; LINE_WIDTH: 0.632486
G1 X133.871 Y120.652 E.03072
; LINE_WIDTH: 0.583791
G1 X133.609 Y120.628 E.0278
; LINE_WIDTH: 0.535096
G1 X133.348 Y120.603 E.02488
; LINE_WIDTH: 0.486401
G1 X133.086 Y120.578 E.02196
; LINE_WIDTH: 0.437705
G1 X132.825 Y120.553 E.01904
; LINE_WIDTH: 0.38901
G1 X132.563 Y120.529 E.01612
; LINE_WIDTH: 0.340315
G1 X132.301 Y120.504 E.0132
; LINE_WIDTH: 0.29162
G1 X132.04 Y120.479 E.01028
; LINE_WIDTH: 0.242925
G1 X131.778 Y120.454 E.00736
; WIPE_START
G1 X132.04 Y120.479 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.575 Y128.093 Z6.96 F42000
G1 X133.091 Y135.421 Z6.96
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.487341
G1 F3000
M204 S6000
G1 X133.353 Y135.397 E.02207
; LINE_WIDTH: 0.536205
G1 X133.615 Y135.372 E.025
; LINE_WIDTH: 0.58507
G1 X133.878 Y135.347 E.02794
; LINE_WIDTH: 0.633935
G1 X134.14 Y135.322 E.03088
; LINE_WIDTH: 0.6828
G1 X134.402 Y135.297 E.03381
; LINE_WIDTH: 0.731665
G1 X134.664 Y135.272 E.03675
; LINE_WIDTH: 0.778722
G1 X134.875 Y135.25 E.03181
; LINE_WIDTH: 0.823313
G1 X135.077 Y135.228 E.03261
; LINE_WIDTH: 0.867
G1 X135.279 Y135.206 E.03464
; LINE_WIDTH: 0.910687
G1 F2846.265
G1 X135.481 Y135.184 E.03666
; LINE_WIDTH: 0.954374
G1 F2697.206
G1 X135.683 Y135.162 E.03869
; LINE_WIDTH: 0.988462
G1 F2591.315
G1 X136.212 Y135.098 E.1056
; WIPE_START
G1 X135.683 Y135.162 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.079 Y134.849 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.241177
G1 F3000
M204 S6000
G1 X138.233 Y134.825 E.00429
; LINE_WIDTH: 0.286392
G1 X138.386 Y134.801 E.00589
; LINE_WIDTH: 0.331606
G1 X138.54 Y134.777 E.00749
; LINE_WIDTH: 0.376821
G1 X138.693 Y134.753 E.0091
; LINE_WIDTH: 0.422035
G1 X138.847 Y134.729 E.0107
; LINE_WIDTH: 0.46725
G1 X139 Y134.706 E.0123
; LINE_WIDTH: 0.490963
G1 X139.007 Y134.705 E.00058
; LINE_WIDTH: 0.516044
G1 X139.145 Y134.681 E.01262
; LINE_WIDTH: 0.564003
G1 X139.283 Y134.657 E.01416
; LINE_WIDTH: 0.611962
G1 X139.42 Y134.633 E.01568
; LINE_WIDTH: 0.659921
G1 X139.558 Y134.609 E.01721
; LINE_WIDTH: 0.70788
G1 X139.696 Y134.585 E.01874
; LINE_WIDTH: 0.755839
G1 X139.833 Y134.561 E.02027
; LINE_WIDTH: 0.803798
G1 X139.971 Y134.537 E.0218
; LINE_WIDTH: 0.853789
G1 X140.469 Y134.441 E.08481
M204 S10000
G1 X141.451 Y134.2 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25536
G1 F1982.064
M204 S6000
G1 X141.309 Y134.2 E.03675
G1 X141.238 Y134.323 E.03675
G1 X141.309 Y134.446 E.03675
G1 X141.451 Y134.446 E.03675
G1 X141.462 Y134.427 E.00567
; WIPE_START
G1 X141.451 Y134.446 E-.02822
G1 X141.309 Y134.446 E-.18295
G1 X141.238 Y134.323 E-.18294
G1 X141.309 Y134.2 E-.18295
G1 X141.451 Y134.2 E-.18293
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.205 Y134.51 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.881497
G1 F2955.393
M204 S6000
G1 X146.65 Y134.51 E.25102
G1 X146.65 Y133.325 E.20587
G1 X145.298 Y134.434 E.3038
; WIPE_START
G1 X146.65 Y133.325 E-.66459
G1 X146.65 Y133.576 E-.09541
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.385 Y131.078 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.239284
G1 F3000
M204 S6000
G1 X147.558 Y130.863 E.00749
; LINE_WIDTH: 0.280428
G1 X147.73 Y130.648 E.01008
M204 S10000
G1 X147.311 Y129.866 F42000
; FEATURE: Top surface
; LINE_WIDTH: 0.827277
G1 F3182.011
M204 S2000
G3 X145.652 Y131.524 I-134.403 J-132.823 E.37837
G1 X143.492 Y133.295 E.45067
G1 X143.184 Y132.993 E.06966
G1 X147.332 Y128.844 E.94656
G2 X147.417 Y127.759 I-4.156 J-.872 E.17609
G1 X142.679 Y132.498 E1.08119
G1 X142.174 Y132.003 E.11408
G1 X147.267 Y126.91 E1.16209
G2 X146.988 Y126.189 I-3.479 J.933 E.12495
G1 X144.864 Y128.313 E.48462
G2 X144.815 Y127.362 I-2.81 J-.332 E.15437
G1 X146.617 Y125.56 E.41106
G2 X146.174 Y125.003 I-4.28 J2.941 E.11493
G1 X144.56 Y126.617 E.36825
G2 X144.192 Y125.985 I-3.609 J1.682 E.11813
G1 X145.675 Y124.502 E.33835
G2 X145.128 Y124.049 I-2.988 J3.05 E.11472
G1 X143.738 Y125.439 E.3171
G2 X143.221 Y124.956 I-4.914 J4.742 E.1142
G1 X144.575 Y123.602 E.3089
G1 X144.022 Y123.155 E.11472
G1 X142.657 Y124.52 E.31143
G2 X142.052 Y124.125 I-5.163 J7.253 E.11661
G1 X143.693 Y122.484 E.37444
; WIPE_START
M204 S6000
G1 X142.279 Y123.898 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.391 Y124.938 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.256722
G1 F3000
M204 S6000
G1 X147.645 Y125.251 E.01258
G1 X147.66 Y125.299 E.00156
; LINE_WIDTH: 0.239584
G1 X147.694 Y125.425 E.00356
; WIPE_START
G1 X147.66 Y125.299 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.971 Y126.733 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.946621
G1 F2722.506
M204 S6000
G3 X148.025 Y127.307 I-12.93 J1.511 E.10871
; LINE_WIDTH: 0.90612
G1 F2862.804
G1 X148.049 Y127.79 E.08678
; LINE_WIDTH: 0.891274
G1 F2917.92
G3 X148.031 Y128.624 I-12.31 J.141 E.14686
; LINE_WIDTH: 0.940227
G1 F2743.734
G3 X147.971 Y129.263 I-11.455 J-.753 E.12002
; WIPE_START
G1 X148.031 Y128.624 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.084 Y131.785 Z6.96 F42000
G1 X133.091 Y135.421 Z6.96
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.438476
G1 F3000
M204 S6000
G1 X132.829 Y135.446 E.01913
; LINE_WIDTH: 0.389611
G1 X132.566 Y135.471 E.01619
; LINE_WIDTH: 0.340746
G1 X132.304 Y135.496 E.01326
; LINE_WIDTH: 0.291881
G1 X132.042 Y135.521 E.01032
; LINE_WIDTH: 0.243016
G1 X131.78 Y135.546 E.00738
; WIPE_START
G1 X132.042 Y135.521 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.419 Y135.134 Z6.96 F42000
G1 X112.215 Y134.514 Z6.96
G1 Z6.56
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.106 J-6.975 E.44642
G1 X122.192 Y120.612 E2.65863
G2 X119.598 Y119.598 I-4.767 J8.37 E.44622
G1 X130.692 Y130.692 E2.50506
G1 X130.692 Y125.308 E.8596
G1 X119.598 Y136.402 E2.50506
G2 X122.192 Y135.388 I-2.173 J-9.383 E.44622
G1 X110.418 Y123.614 E2.65864
G3 X112.215 Y121.485 I7.623 J4.611 E.44667
; CHANGE_LAYER
; Z_HEIGHT: 7.12
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.496 Y122.164 E-.37591
G1 X110.989 Y122.772 E-.30072
G1 X110.866 Y122.954 E-.08336
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 13/51
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z7.12 I.117 J1.7 P1  F42000
G1 X132.504 Y121.464 Z7.12
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X138.24 Y122.567 I-6.091 J47.145 E.93314
G3 X142.427 Y124.065 I-6.124 J23.72 E.71115
G3 X144.941 Y125.758 I-3.953 J8.582 E.48603
G3 X145.953 Y127.46 I-2.495 J2.635 E.32017
G3 X145.43 Y129.674 I-2.706 J.53 E.37443
G3 X143.717 Y131.216 I-5.086 J-3.928 E.36998
G3 X139.802 Y132.972 I-8.987 J-14.793 E.68692
G3 X132.504 Y134.535 I-12.422 J-40.167 E1.19326
G1 X132.504 Y121.584 E2.06794
; WIPE_START
M204 S6000
G1 X133.871 Y121.663 E-.52037
G1 X134.493 Y121.768 E-.23963
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.601 Y129.103 Z7.52 F42000
G1 X138.259 Y134.874 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G2 X143.192 Y133.121 I-6.316 J-25.592 E.83727
G1 X145.138 Y135.03 E.43524
G1 X147.38 Y133.194 E.46285
G1 X147.38 Y135.24 E.32681
G1 X138.306 Y135.24 E1.44889
G1 X138.275 Y134.993 E.03979
; WIPE_START
G1 X139.643 Y134.489 E-.55425
G1 X140.159 Y134.324 E-.20575
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.746 Y127.587 Z7.52 F42000
G1 X147.38 Y120.76 Z7.52
G1 Z7.12
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y122.813 E.32792
G1 X145.178 Y121.04 E.45145
G1 X145.244 Y120.853 E.0316
G1 X143.191 Y122.885 E.4612
G2 X138.255 Y121.128 I-10.873 J22.738 E.83808
G1 X138.3 Y120.76 E.05928
G1 X147.26 Y120.76 E1.43068
; WIPE_START
G1 X147.377 Y122.756 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.801 Y121.827 Z7.52 F42000
G1 X131.105 Y120.76 Z7.52
G1 Z7.12
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.105 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.21075
G3 X121.619 Y136.361 I-8.792 J-12.756 E.35284
G3 X118.124 Y118.82 I-3.813 J-8.359 E5.28753
G3 X122.587 Y120.152 I-.304 J9.153 E.7519
G1 X123.522 Y120.76 E.17803
G1 X130.985 Y120.76 E1.19159
; WIPE_START
G1 X131.001 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.54 Y121.568 Z7.52 F42000
G1 X148.08 Y120.06 Z7.52
G1 Z7.12
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y124.332 E.68216
G1 X147.706 Y123.974 E.08264
G1 X145.159 Y121.922 E.52233
G1 X143.321 Y123.74 E.41276
G2 X139.397 Y122.167 I-9.88 J18.96 E.6761
G2 X133.98 Y120.971 I-11.941 J41.228 E.88647
G1 X131.804 Y120.656 E.35099
G1 X131.804 Y135.343 E2.34526
G2 X138.173 Y134.173 I-7.006 J-56.049 E1.03454
G2 X142.785 Y132.539 I-6.164 J-24.717 E.78243
G1 X143.315 Y132.262 E.09551
G1 X145.18 Y134.091 E.41719
G1 X148.08 Y131.716 E.5986
G1 X148.08 Y135.94 E.67451
G1 X123.729 Y135.94 E3.88823
G3 X119.664 Y137.713 I-6.215 J-8.701 E.71332
G3 X118.153 Y118.12 I-1.857 J-9.712 E5.31338
G3 X122.951 Y119.554 I-.331 J9.85 E.80839
G1 X123.729 Y120.06 E.14822
G1 X147.96 Y120.06 E3.86907
; WIPE_START
G1 X148.016 Y122.059 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.78 Y119.36 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.937 Y136.64 E3.96688
G3 X107.236 Y127.415 I-6.124 J-8.643 E3.79243
G3 X118.182 Y117.421 I10.57 J.586 E2.62168
G3 X123.937 Y119.36 I-.402 J10.702 E.98309
G1 X148.66 Y119.36 E3.94772
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7.52 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7.52
M73 P61 R6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z7.52 F4000
            G39.3 S1
            G0 Z7.52 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X146.758 Y121.351 F42000
G1 Z7.12
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G2 X146.673 Y121.498 I-.032 J.08 E.03804
G1 X146.723 Y121.498 E.00776
; WIPE_START
G1 X146.673 Y121.498 E-.12457
G1 X146.631 Y121.424 E-.21181
G1 X146.673 Y121.351 E-.21181
G1 X146.758 Y121.351 E-.21181
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.175 Y121.555 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 1.2579
G1 F1977.639
M204 S6000
G1 X143.033 Y121.555 E.03691
G1 X142.962 Y121.678 E.03692
G1 X143.033 Y121.802 E.03692
G1 X143.175 Y121.802 E.03692
G1 X143.186 Y121.782 E.00576
M204 S10000
G1 X142.191 Y121.56 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.8634
G1 F3000
M204 S6000
G1 X141.939 Y121.511 E.04352
; LINE_WIDTH: 0.83683
G1 X141.673 Y121.459 E.04428
; LINE_WIDTH: 0.79588
G1 X141.536 Y121.436 E.02139
; LINE_WIDTH: 0.748391
G1 X141.4 Y121.412 E.01988
; LINE_WIDTH: 0.700901
G1 X141.263 Y121.388 E.01838
; LINE_WIDTH: 0.653411
G1 X141.126 Y121.364 E.01688
; LINE_WIDTH: 0.605921
G1 X140.99 Y121.341 E.01537
; LINE_WIDTH: 0.558432
G1 X140.853 Y121.317 E.01387
; LINE_WIDTH: 0.509806
G1 X140.71 Y121.292 E.01292
; LINE_WIDTH: 0.462825
G1 X140.559 Y121.268 E.01195
; LINE_WIDTH: 0.418417
G1 X140.408 Y121.245 E.0104
; LINE_WIDTH: 0.374008
G1 X140.257 Y121.222 E.00885
; LINE_WIDTH: 0.329599
G1 X140.106 Y121.198 E.0073
; LINE_WIDTH: 0.28519
G1 X139.955 Y121.175 E.00576
; LINE_WIDTH: 0.240781
G1 X139.804 Y121.151 E.00421
; WIPE_START
G1 X139.955 Y121.175 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.87 Y121.387 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.861581
G1 F3000
M204 S6000
G1 X137.549 Y120.925 E.09517
; LINE_WIDTH: 0.891947
G1 F2915.376
G1 X137.531 Y120.9 E.00552
; LINE_WIDTH: 0.934128
G1 F2764.294
G1 X137.513 Y120.874 E.00582
; LINE_WIDTH: 0.976309
G1 F2628.099
G1 X137.495 Y120.848 E.00612
; LINE_WIDTH: 0.974392
G1 F2633.998
G1 X137.284 Y120.825 E.04125
; LINE_WIDTH: 0.928406
G1 F2783.864
G1 X137.074 Y120.802 E.03903
; LINE_WIDTH: 0.882421
G1 F2951.812
G1 X136.864 Y120.779 E.03681
; LINE_WIDTH: 0.836435
G1 F3000
G1 X136.653 Y120.756 E.03459
; LINE_WIDTH: 0.789534
G1 X136.434 Y120.732 E.03362
; LINE_WIDTH: 0.743283
G1 X136.201 Y120.71 E.03333
; LINE_WIDTH: 0.698411
G1 X135.968 Y120.688 E.03093
; LINE_WIDTH: 0.653538
G1 X135.734 Y120.665 E.02853
; LINE_WIDTH: 0.608666
G1 X135.501 Y120.643 E.02613
; LINE_WIDTH: 0.563299
G1 X135.262 Y120.62 E.02423
; LINE_WIDTH: 0.520158
G1 X135.02 Y120.6 E.02216
; LINE_WIDTH: 0.479597
G1 X134.778 Y120.579 E.01992
; LINE_WIDTH: 0.439037
G1 X134.536 Y120.559 E.01767
; LINE_WIDTH: 0.398477
G1 X134.294 Y120.539 E.01542
; LINE_WIDTH: 0.357707
G1 X134.05 Y120.518 E.0133
; LINE_WIDTH: 0.31747
G1 X133.759 Y120.497 E.01311
; LINE_WIDTH: 0.277913
G1 X133.469 Y120.476 E.01048
; LINE_WIDTH: 0.238356
G1 X133.179 Y120.455 E.00785
; WIPE_START
G1 X133.469 Y120.476 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.887 Y128.097 Z7.52 F42000
G1 X134.292 Y135.461 Z7.52
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.3537
G1 F3000
M204 S6000
G1 X134.001 Y135.486 E.01551
; LINE_WIDTH: 0.311126
G1 X133.727 Y135.505 E.01197
; LINE_WIDTH: 0.274105
G1 X133.453 Y135.525 E.00965
; LINE_WIDTH: 0.237084
G1 X133.179 Y135.545 E.00733
M204 S10000
G1 X134.292 Y135.461 F42000
; LINE_WIDTH: 0.40166
G1 F3000
M204 S6000
G1 X134.579 Y135.438 E.01854
; LINE_WIDTH: 0.449427
G1 X134.867 Y135.414 E.02169
; LINE_WIDTH: 0.497194
G1 X135.155 Y135.39 E.02484
; LINE_WIDTH: 0.542529
G1 X135.382 Y135.368 E.02198
; LINE_WIDTH: 0.585109
G1 X135.604 Y135.347 E.0237
; LINE_WIDTH: 0.627249
G1 X135.827 Y135.326 E.02585
; LINE_WIDTH: 0.669388
G1 X136.049 Y135.305 E.028
; LINE_WIDTH: 0.711527
G1 X136.272 Y135.284 E.03015
; LINE_WIDTH: 0.756154
G1 X136.492 Y135.26 E.03222
; LINE_WIDTH: 0.802657
G1 X136.706 Y135.238 E.0334
; LINE_WIDTH: 0.848354
G1 X136.919 Y135.215 E.03563
; LINE_WIDTH: 0.894051
G1 F2907.449
G1 X137.132 Y135.192 E.03787
; LINE_WIDTH: 0.939748
G1 F2745.337
G1 X137.345 Y135.169 E.0401
; LINE_WIDTH: 0.981669
G1 F2611.747
G1 X137.935 Y135.099 E.11675
; WIPE_START
G1 X137.345 Y135.169 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.805 Y134.849 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.238696
G1 F3000
M204 S6000
G1 X139.948 Y134.827 E.00391
; LINE_WIDTH: 0.278954
G1 X140.092 Y134.805 E.00524
; LINE_WIDTH: 0.319211
G1 X140.235 Y134.783 E.00657
; LINE_WIDTH: 0.359468
G1 X140.378 Y134.761 E.0079
; LINE_WIDTH: 0.400632
G1 X140.509 Y134.74 E.00852
; LINE_WIDTH: 0.442452
G1 X140.639 Y134.719 E.00967
; LINE_WIDTH: 0.484015
G1 X140.769 Y134.698 E.01091
; LINE_WIDTH: 0.529447
G1 X140.91 Y134.673 E.01341
; LINE_WIDTH: 0.577935
G1 X141.046 Y134.65 E.01442
; LINE_WIDTH: 0.625467
G1 X141.182 Y134.626 E.01592
; LINE_WIDTH: 0.672998
G1 X141.318 Y134.602 E.01741
; LINE_WIDTH: 0.720529
G1 X141.454 Y134.578 E.01891
; LINE_WIDTH: 0.76806
G1 X141.59 Y134.555 E.02041
; LINE_WIDTH: 0.815591
G1 X141.726 Y134.531 E.02191
; LINE_WIDTH: 0.860031
G1 X142.193 Y134.44 E.0803
M204 S10000
G1 X143.176 Y134.199 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25626
G1 F1980.494
M204 S6000
G1 X143.034 Y134.199 E.03681
G1 X142.963 Y134.322 E.03681
G1 X143.034 Y134.445 E.03681
G1 X143.176 Y134.445 E.03681
G1 X143.187 Y134.426 E.0057
; WIPE_START
G1 X143.176 Y134.445 E-.02835
G1 X143.034 Y134.445 E-.18292
G1 X142.963 Y134.322 E-.18291
G1 X143.034 Y134.199 E-.18292
G1 X143.176 Y134.199 E-.18291
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.765 Y134.509 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G2 X146.68 Y134.656 I-.032 J.08 E.03804
G1 X146.73 Y134.656 E.00776
; WIPE_START
G1 X146.68 Y134.656 E-.12457
G1 X146.638 Y134.583 E-.21181
G1 X146.68 Y134.509 E-.21181
G1 X146.765 Y134.509 E-.21181
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.151 Y131.149 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242704
G1 F3000
M204 S6000
G1 X148.43 Y130.869 E.01106
M204 S10000
G1 X148.5 Y125.598 F42000
; FEATURE: Top surface
; LINE_WIDTH: 0.827787
G1 F3179.718
M204 S2000
G2 X147.313 Y124.422 I-27.087 J26.146 E.26976
G1 X145.199 Y122.719 E.43829
G1 X144.908 Y123.007 E.06605
G1 X148.185 Y126.284 E.7482
G1 X148.185 Y127.284 E.16157
G1 X144.405 Y123.504 E.86305
G1 X143.902 Y124.002 E.11425
G1 X148.185 Y128.285 E.97791
G1 X148.185 Y129.286 E.16157
G1 X146.586 Y127.686 E.36525
G3 X146.538 Y128.639 I-3.266 J.316 E.15466
G1 X148.185 Y130.286 E.37605
G1 X148.185 Y130.649 E.05857
G1 X147.898 Y131 E.07319
G1 X146.283 Y129.385 E.36889
G3 X145.916 Y130.018 I-6.985 J-3.621 E.11828
G1 X147.398 Y131.501 E.33847
G1 X146.851 Y131.954 E.11475
G1 X145.459 Y130.562 E.31783
G3 X144.942 Y131.046 I-2.868 J-2.548 E.11447
G1 X146.301 Y132.405 E.31027
G1 X145.75 Y132.855 E.11481
G1 X144.15 Y131.255 E.36535
; WIPE_START
M204 S6000
G1 X145.565 Y132.669 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.328 Y130.242 Z7.52 F42000
G1 X112.215 Y121.485 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I5.897 J6.797 E.44665
G1 X122.192 Y135.388 E2.65863
G3 X119.598 Y136.402 I-4.766 J-8.367 E.44621
G1 X130.51 Y125.49 E2.46397
G1 X130.51 Y130.51 E.8015
G1 X119.598 Y119.598 E2.46397
G3 X122.192 Y120.612 I-2.173 J9.382 E.44621
G1 X110.418 Y132.386 E2.65863
G2 X112.214 Y134.515 I7.931 J-4.868 E.44643
; CHANGE_LAYER
; Z_HEIGHT: 7.68
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.155 Y133.445 E-.5721
G1 X110.873 Y133.039 E-.1879
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 14/51
; update layer progress
M73 L14
M991 S0 P13 ;notify layer change
M106 S198.9
; OBJECT_ID: 15
M204 S10000
G17
G3 Z7.68 I.82 J1.493 P1  F42000
G1 X132.322 Y121.252 Z7.68
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G3 X135.495 Y121.647 I-6.065 J61.66 E.5105
G3 X142.232 Y123.27 I-5.292 J36.764 E1.10816
G3 X145.391 Y124.752 I-5.465 J15.754 E.55817
G3 X147.113 Y126.27 I-3.411 J5.606 E.3684
G3 X147.707 Y128.386 I-2.244 J1.771 E.36019
G3 X146.818 Y130.086 I-3.375 J-.681 E.31034
G3 X144.856 Y131.567 I-5.932 J-5.82 E.39397
M73 P62 R6
G3 X140.998 Y133.138 I-9.538 J-17.893 E.66636
G3 X132.322 Y134.747 I-12.687 J-44.218 E1.41112
G1 X132.322 Y121.372 E2.13563
; WIPE_START
M204 S6000
G1 X134.319 Y121.482 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.923 Y120.76 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.923 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.18171
G3 X121.621 Y136.36 I-8.971 J-13.059 E.35249
G3 X118.095 Y118.818 I-3.815 J-8.358 E5.28324
G3 X122.588 Y120.153 I-.275 J9.156 E.75691
G1 X123.522 Y120.76 E.17775
G1 X130.803 Y120.76 E1.16255
; WIPE_START
G1 X130.819 Y122.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.397 Y121.844 Z8.08 F42000
G1 X147.38 Y120.76 Z8.08
G1 Z7.68
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y121.482 E.11538
G1 X146.901 Y121.108 E.09711
G1 X144.952 Y122.904 E.42318
G2 X139.977 Y121.128 I-10.866 J22.579 E.84507
G1 X140.022 Y120.76 E.05925
G1 X147.26 Y120.76 E1.15571
; WIPE_START
G1 X147.38 Y121.482 E-.27834
G1 X146.901 Y121.108 E-.23111
G1 X146.416 Y121.555 E-.25055
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.428 Y129.123 Z8.08 F42000
G1 X144.905 Y133.126 Z8.08
G1 Z7.68
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.019 Y135.24 E.47733
G1 X140.029 Y135.24 E1.11618
G1 X139.981 Y134.874 E.05895
G2 X144.796 Y133.177 I-6.336 J-25.659 E.81649
; WIPE_START
G1 X146.262 Y134.538 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.61 Y129.409 Z8.08 F42000
G1 X131.622 Y121.252 Z8.08
G1 Z7.68
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.622 Y135.522 E2.27846
G2 X140.23 Y134.086 I-4.115 J-51.171 E1.39502
G2 X144.518 Y132.534 I-6.482 J-24.623 E.72911
G1 X145.033 Y132.264 E.09288
G1 X146.877 Y134.109 E.41646
G1 X148.08 Y133.126 E.2481
G1 X148.08 Y135.94 E.44942
G1 X123.729 Y135.94 E3.88824
G3 X119.666 Y137.713 I-6.2 J-8.668 E.7131
G3 X122.952 Y119.555 I-1.857 J-9.713 E6.1226
G1 X123.729 Y120.06 E.14791
G1 X148.08 Y120.06 E3.88824
G1 X148.08 Y122.916 E.45603
G1 X146.938 Y122.025 E.23122
G1 X145.065 Y123.751 E.40674
G2 X140.178 Y121.9 I-10.517 J20.389 E.83625
G2 X131.622 Y120.477 I-12.743 J50.182 E1.38652
G1 X131.622 Y121.132 E.10462
; WIPE_START
G1 X131.622 Y123.132 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.077 Y121.493 Z8.08 F42000
G1 X148.78 Y119.36 Z8.08
G1 Z7.68
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X148.78 Y136.64 E2.75918
G1 X123.936 Y136.64 E3.96688
G3 X107.234 Y127.445 I-6.124 J-8.643 E3.78757
G3 X118.153 Y117.42 I10.572 J.556 E2.62192
G3 X123.936 Y119.36 I-.374 J10.704 E.98774
G1 X148.66 Y119.36 E3.94772
; WIPE_START
M204 S6000
G1 X148.674 Y121.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.08 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.08
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z8.08 F4000
            G39.3 S1
            G0 Z8.08 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X144.495 Y121.973 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.718137
G1 F3762.793
M204 S6000
G1 X144.833 Y122.131 E.05084
G1 X145.617 Y121.408 E.14555
G1 X144.605 Y121.408 E.13808
G1 X144.518 Y121.855 E.06212
M204 S10000
G1 X143.915 Y121.56 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.853164
G1 F3000
M204 S6000
G1 X143.415 Y121.463 E.08517
; LINE_WIDTH: 0.802575
G1 X143.278 Y121.439 E.02159
; LINE_WIDTH: 0.755003
G1 X143.142 Y121.415 E.02009
; LINE_WIDTH: 0.707431
G1 X143.005 Y121.391 E.01858
; LINE_WIDTH: 0.659859
G1 X142.868 Y121.367 E.01708
; LINE_WIDTH: 0.612287
G1 X142.732 Y121.344 E.01557
; LINE_WIDTH: 0.564715
G1 X142.595 Y121.32 E.01407
; LINE_WIDTH: 0.515993
G1 X142.452 Y121.295 E.01313
; LINE_WIDTH: 0.468457
G1 X142.298 Y121.271 E.01238
; LINE_WIDTH: 0.423025
G1 X142.144 Y121.247 E.01076
; LINE_WIDTH: 0.377592
G1 X141.99 Y121.223 E.00915
; LINE_WIDTH: 0.332159
G1 X141.836 Y121.199 E.00754
; LINE_WIDTH: 0.286726
G1 X141.682 Y121.175 E.00592
; LINE_WIDTH: 0.241293
G1 X141.528 Y121.151 E.00431
; WIPE_START
G1 X141.682 Y121.175 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.653 Y120.898 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.983526
G1 F2606.131
M204 S6000
G1 X139.317 Y120.859 E.06655
; LINE_WIDTH: 0.956534
G1 F2690.24
M73 P63 R6
G1 X138.977 Y120.821 E.06535
; LINE_WIDTH: 0.921929
G1 F2806.353
G1 X138.788 Y120.8 E.03469
; LINE_WIDTH: 0.881183
G1 F2956.613
G1 X138.6 Y120.78 E.03292
; LINE_WIDTH: 0.840437
G1 F3000
G1 X138.411 Y120.76 E.03116
; LINE_WIDTH: 0.799205
G1 X138.218 Y120.739 E.03008
; LINE_WIDTH: 0.762785
G1 X138.064 Y120.723 E.02269
; LINE_WIDTH: 0.731275
G1 X137.907 Y120.707 E.02207
; LINE_WIDTH: 0.695159
G1 X137.694 Y120.687 E.02797
; LINE_WIDTH: 0.654741
G1 X137.482 Y120.667 E.02601
; LINE_WIDTH: 0.614323
G1 X137.27 Y120.647 E.02404
; LINE_WIDTH: 0.573671
G1 X137.055 Y120.626 E.02232
; LINE_WIDTH: 0.530592
G1 X136.802 Y120.604 E.02382
; LINE_WIDTH: 0.484657
G1 X136.519 Y120.58 E.02358
; LINE_WIDTH: 0.438074
G1 X136.237 Y120.557 E.02057
; LINE_WIDTH: 0.391491
G1 X135.954 Y120.534 E.01755
; LINE_WIDTH: 0.344728
G1 X135.669 Y120.51 E.01464
; LINE_WIDTH: 0.304164
G1 X135.413 Y120.492 E.01077
; LINE_WIDTH: 0.269929
G1 X135.157 Y120.474 E.00877
; LINE_WIDTH: 0.235694
G1 X134.902 Y120.455 E.00676
; WIPE_START
G1 X135.157 Y120.474 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.048 Y123.756 Z8.08 F42000
G1 X147.502 Y126.354 Z8.08
G1 Z7.68
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.861347
G1 F3035.741
M204 S2000
G1 X148.185 Y125.671 E.1633
G1 X148.185 Y124.623 E.17725
G1 X147.273 Y125.535 E.21818
G2 X146.744 Y125.016 I-8.762 J8.398 E.12536
G1 X148.086 Y123.674 E.32085
G1 X147.497 Y123.215 E.12629
G1 X146.156 Y124.556 E.32072
G2 X145.524 Y124.14 I-3.471 J4.581 E.12806
G1 X147.132 Y122.531 E.38468
; WIPE_START
M204 S6000
G1 X145.718 Y123.946 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.568 Y131.531 Z8.08 F42000
G1 X146.804 Y133.64 Z8.08
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.868867
G1 F3005.249
M204 S2000
G1 X148.185 Y132.258 E.33375
G1 X148.185 Y131.199 E.18087
G1 X146.497 Y132.887 E.40785
G1 X145.968 Y132.358 E.12789
G1 X148.5 Y129.825 E.61181
; WIPE_START
M204 S6000
G1 X147.086 Y131.24 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.893 Y134.209 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.23974
G1 F2009.718
M204 S6000
G1 X144.753 Y134.209 E.03575
G1 X144.683 Y134.331 E.03575
G1 X144.753 Y134.452 E.03575
G1 X144.893 Y134.452 E.03575
G1 X144.903 Y134.435 E.00509
M204 S10000
G1 X143.917 Y134.44 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.864006
G1 F3000
M204 S6000
G1 X143.472 Y134.527 E.07708
; LINE_WIDTH: 0.824033
G1 X143.337 Y134.55 E.02191
; LINE_WIDTH: 0.776906
G1 X143.203 Y134.574 E.02044
; LINE_WIDTH: 0.729778
G1 X143.069 Y134.597 E.01897
; LINE_WIDTH: 0.68265
G1 X142.934 Y134.621 E.01751
; LINE_WIDTH: 0.635522
G1 X142.8 Y134.645 E.01604
; LINE_WIDTH: 0.588395
G1 X142.665 Y134.668 E.01457
; LINE_WIDTH: 0.540237
G1 X142.525 Y134.693 E.01365
; LINE_WIDTH: 0.496339
G1 X142.404 Y134.712 E.01053
; LINE_WIDTH: 0.457542
G1 X142.283 Y134.731 E.00945
; LINE_WIDTH: 0.418745
G1 X142.162 Y134.751 E.00836
; LINE_WIDTH: 0.379712
G1 X142.039 Y134.771 E.00735
; LINE_WIDTH: 0.336492
G1 X141.87 Y134.797 E.00847
; LINE_WIDTH: 0.289322
G1 X141.7 Y134.823 E.00662
; LINE_WIDTH: 0.242151
G1 X141.53 Y134.849 E.00477
; WIPE_START
G1 X141.7 Y134.823 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.657 Y135.099 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.975785
G1 F2629.71
M204 S6000
G1 X139.017 Y135.175 E.1259
; LINE_WIDTH: 0.928339
G1 F2784.097
G1 X138.805 Y135.198 E.03936
; LINE_WIDTH: 0.883102
G1 F2949.177
G1 X138.592 Y135.22 E.03716
; LINE_WIDTH: 0.837865
G1 F3000
G1 X138.38 Y135.243 E.03496
; LINE_WIDTH: 0.792628
G1 X138.168 Y135.265 E.03275
; LINE_WIDTH: 0.746609
G1 X137.948 Y135.289 E.03157
; LINE_WIDTH: 0.702442
G1 X137.727 Y135.31 E.02952
; LINE_WIDTH: 0.660731
G1 X137.506 Y135.33 E.02741
; LINE_WIDTH: 0.619021
G1 X137.284 Y135.351 E.02529
; LINE_WIDTH: 0.577311
G1 X137.063 Y135.372 E.02318
; LINE_WIDTH: 0.535192
G1 X136.838 Y135.393 E.02146
; LINE_WIDTH: 0.493814
G1 X136.595 Y135.414 E.02074
; LINE_WIDTH: 0.453487
G1 X136.353 Y135.434 E.0185
; LINE_WIDTH: 0.41316
G1 X136.11 Y135.454 E.01626
; LINE_WIDTH: 0.372632
G1 X135.865 Y135.474 E.01415
; LINE_WIDTH: 0.330011
G1 X135.542 Y135.498 E.01551
; LINE_WIDTH: 0.285438
G1 X135.219 Y135.521 E.01222
; LINE_WIDTH: 0.240865
G1 X134.896 Y135.545 E.00892
; WIPE_START
G1 X135.219 Y135.521 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.594 Y135.188 Z8.08 F42000
G1 X112.214 Y134.515 Z8.08
G1 Z7.68
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.165 J-7.018 E.44644
G1 X122.192 Y120.612 E2.65863
G2 X119.598 Y119.598 I-4.766 J8.368 E.44621
G1 X130.328 Y130.328 E2.42288
G1 X130.328 Y125.672 E.74339
G1 X119.598 Y136.402 E2.42289
G2 X122.192 Y135.388 I-2.173 J-9.383 E.44622
G1 X110.418 Y123.614 E2.65863
G3 X112.214 Y121.484 I7.716 J4.683 E.4466
; CHANGE_LAYER
; Z_HEIGHT: 8.24
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.155 Y122.555 E-.57217
G1 X110.873 Y122.961 E-.18783
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 15/51
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z8.24 I.188 J1.693 P1  F42000
G1 X130.685 Y120.76 Z8.24
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.741 Y120.76 E.00891
G1 X130.741 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.15267
G3 X121.623 Y136.359 I-7.688 J-10.88 E.35236
G3 X118.066 Y118.817 I-3.817 J-8.358 E5.27902
G3 X122.59 Y120.154 I-.248 J9.16 E.76184
G1 X123.522 Y120.76 E.17743
G1 X130.565 Y120.76 E1.1246
M204 S10000
G1 X131.441 Y120.3 F42000
G1 F3215.099
M204 S6000
G1 X131.441 Y135.94 E2.49728
G1 X123.729 Y135.94 E1.23131
G3 X119.667 Y137.713 I-6.186 J-8.635 E.71291
G3 X118.095 Y118.118 I-1.859 J-9.711 E5.30461
G3 X122.954 Y119.556 I-.275 J9.856 E.8183
G1 X123.729 Y120.06 E.14759
G1 X131.441 Y120.06 E1.23131
G1 X131.441 Y120.18 E.01925
; WIPE_START
G1 X131.441 Y122.18 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.002 Y121.138 Z8.64 F42000
G1 X141.75 Y120.76 Z8.64
G1 Z8.24
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y120.76 E.89902
G1 X147.38 Y123.27 E.40079
G2 X143.101 Y121.513 I-10.857 J20.365 E.73992
G2 X141.703 Y121.127 I-8.598 J28.331 E.23151
G1 X141.735 Y120.879 E.03989
; WIPE_START
G1 X143.734 Y120.836 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.122 Y120.282 Z8.64 F42000
G1 X133.074 Y120.06 Z8.64
G1 Z8.24
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E2.39605
G1 X148.08 Y124.566 E.71952
G2 X145.447 Y123.101 I-8.312 J11.837 E.48201
G2 X139.448 Y121.331 I-11.93 J29.394 E1.00032
G2 X133.058 Y120.463 I-10.749 J55.132 E1.0303
G1 X133.07 Y120.18 E.04521
; WIPE_START
G1 X135.069 Y120.164 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.207 Y127.121 Z8.64 F42000
G1 X141.703 Y134.874 Z8.64
G1 Z8.24
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X146.741 Y133.064 I-5.832 J-24.14 E.85646
G1 X147.38 Y132.727 E.11537
G1 X147.38 Y135.24 E.40139
G1 X141.751 Y135.24 E.89893
G1 X141.719 Y134.993 E.03979
; WIPE_START
G1 X143.168 Y134.466 E-.5862
G1 X143.602 Y134.322 E-.1738
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.02 Y135.196 Z8.64 F42000
M73 P64 R6
G1 X133.058 Y135.537 Z8.64
G1 Z8.24
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X142.453 Y133.946 I-3.451 J-48.915 E1.52391
G2 X146.93 Y132.173 I-5.851 J-21.31 E.77057
G2 X148.08 Y131.431 I-4.99 J-8.995 E.21866
G1 X148.08 Y135.94 E.72004
G1 X133.074 Y135.94 E2.39612
G1 X133.062 Y135.657 E.04521
; WIPE_START
G1 X134.967 Y135.357 E-.73266
G1 X135.038 Y135.348 E-.02734
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.518 Y127.869 Z8.64 F42000
G1 X132.14 Y121.09 Z8.64
M73 P64 R5
G1 Z8.24
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.14 Y134.91 E2.20675
G2 X140.817 Y133.652 I-3.266 J-53.077 E1.40148
G2 X145.942 Y131.901 I-5.443 J-24.312 E.86657
G2 X148.143 Y130.479 I-4.575 J-9.489 E.41942
G2 X148.78 Y129.795 I-2.876 J-3.321 E.14954
G1 X148.78 Y136.64 E1.09292
G1 X123.936 Y136.64 E3.96689
G3 X111.1 Y136.192 I-6.124 J-8.657 E2.20303
G3 X111.1 Y119.808 I6.723 J-8.192 E2.99022
G3 X118.124 Y117.419 I6.71 J8.205 E1.21024
G3 X123.936 Y119.36 I-.345 J10.708 E.99239
G1 X148.78 Y119.36 E3.96689
G1 X148.78 Y126.201 E1.09239
G2 X147.108 Y124.748 I-5.022 J4.09 E.35545
G2 X143.579 Y123.136 I-8.886 J14.782 E.62074
G2 X136.039 Y121.478 I-12.502 J38.883 E1.23463
G2 X132.26 Y121.099 I-9.06 J71.14 E.60651
; WIPE_START
M204 S6000
G1 X132.243 Y123.099 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.64 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.64
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z8.64 F4000
            G39.3 S1
            G0 Z8.64 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X136.624 Y120.455 F42000
G1 Z8.24
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242414
G1 F3000
M204 S6000
G1 X136.984 Y120.481 E.01007
; LINE_WIDTH: 0.290087
G1 X137.344 Y120.507 E.01399
; LINE_WIDTH: 0.337109
G1 X137.627 Y120.53 E.01406
; LINE_WIDTH: 0.383326
G1 X137.908 Y120.553 E.01693
; LINE_WIDTH: 0.429371
G1 X138.189 Y120.576 E.0199
; LINE_WIDTH: 0.475417
G1 X138.47 Y120.599 E.02286
; LINE_WIDTH: 0.515022
G1 X138.656 Y120.615 E.01679
; LINE_WIDTH: 0.547992
G1 X138.839 Y120.632 E.01792
; LINE_WIDTH: 0.587747
G1 X139.085 Y120.655 E.02635
; LINE_WIDTH: 0.63433
G1 X139.328 Y120.678 E.02868
; LINE_WIDTH: 0.680672
G1 X139.572 Y120.702 E.03127
; LINE_WIDTH: 0.725285
G1 X139.784 Y120.723 E.02945
; LINE_WIDTH: 0.767866
G1 X139.993 Y120.744 E.03101
; LINE_WIDTH: 0.812485
G1 X140.21 Y120.768 E.0346
; LINE_WIDTH: 0.859068
G1 X140.424 Y120.791 E.03615
; LINE_WIDTH: 0.905156
G1 F2866.319
G1 X140.637 Y120.814 E.03841
; LINE_WIDTH: 0.94617
G1 F2723.994
G1 X141.01 Y120.856 E.07087
; LINE_WIDTH: 0.98075
G1 F2614.536
G1 X141.38 Y120.898 E.07296
; WIPE_START
G1 X141.01 Y120.856 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.253 Y121.151 Z8.64 F42000
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 0.241991
G1 F3000
M204 S6000
G1 X143.411 Y121.176 E.00444
; LINE_WIDTH: 0.288819
G1 X143.569 Y121.2 E.00615
; LINE_WIDTH: 0.335647
G1 X143.727 Y121.225 E.00786
; LINE_WIDTH: 0.382475
G1 X143.885 Y121.25 E.00957
; LINE_WIDTH: 0.429303
G1 X144.043 Y121.275 E.01128
; LINE_WIDTH: 0.47613
G1 X144.201 Y121.299 E.01299
; LINE_WIDTH: 0.524077
G1 X144.342 Y121.324 E.01322
; LINE_WIDTH: 0.57221
G1 X144.477 Y121.347 E.01409
; LINE_WIDTH: 0.619166
G1 X144.611 Y121.371 E.01555
; LINE_WIDTH: 0.666122
G1 X144.746 Y121.394 E.01701
; LINE_WIDTH: 0.713077
G1 X144.88 Y121.418 E.01848
; LINE_WIDTH: 0.760033
G1 X145.015 Y121.441 E.01994
; LINE_WIDTH: 0.806989
G1 X145.15 Y121.465 E.0214
; LINE_WIDTH: 0.855279
G1 X145.639 Y121.56 E.08359
M204 S10000
G1 X146.558 Y121.721 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.1994
G1 F2084.839
M204 S6000
G1 X146.423 Y121.721 E.03322
G1 X146.356 Y121.838 E.03322
G1 X146.423 Y121.955 E.03322
G1 X146.558 Y121.955 E.03322
G1 X146.566 Y121.942 E.00367
; WIPE_START
G1 X146.558 Y121.955 E-.02042
G1 X146.423 Y121.955 E-.18489
G1 X146.356 Y121.838 E-.1849
G1 X146.423 Y121.721 E-.1849
G1 X146.558 Y121.721 E-.18489
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.559 Y129.354 Z8.64 F42000
G1 X146.56 Y134.05 Z8.64
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 1.19548
G1 F2092.439
M204 S6000
G1 X146.426 Y134.05 E.03297
G1 X146.358 Y134.167 E.03298
G1 X146.426 Y134.283 E.03298
G1 X146.567 Y134.271 E.03488
M204 S10000
G1 X145.642 Y134.439 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.871571
G1 F2994.434
M204 S6000
G1 X145.235 Y134.519 E.07106
; LINE_WIDTH: 0.841006
G1 F3000
G1 X145.115 Y134.541 E.02006
; LINE_WIDTH: 0.798223
G1 X144.995 Y134.562 E.01887
; LINE_WIDTH: 0.755441
M73 P65 R5
G1 X144.875 Y134.584 E.01768
; LINE_WIDTH: 0.712659
G1 X144.755 Y134.605 E.01649
; LINE_WIDTH: 0.669339
G1 X144.632 Y134.627 E.01566
; LINE_WIDTH: 0.627225
G1 X144.515 Y134.647 E.01376
; LINE_WIDTH: 0.586841
G1 X144.397 Y134.667 E.01266
; LINE_WIDTH: 0.545632
G1 X144.275 Y134.688 E.01202
; LINE_WIDTH: 0.501634
G1 X144.132 Y134.711 E.01268
; LINE_WIDTH: 0.455587
G1 X143.988 Y134.734 E.01115
; LINE_WIDTH: 0.40954
G1 X143.844 Y134.757 E.00962
; LINE_WIDTH: 0.363275
G1 X143.699 Y134.781 E.00815
; LINE_WIDTH: 0.319793
G1 X143.551 Y134.803 E.00681
; LINE_WIDTH: 0.279304
G1 X143.403 Y134.826 E.00543
; LINE_WIDTH: 0.238815
G1 X143.255 Y134.849 E.00405
; WIPE_START
G1 X143.403 Y134.826 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.38 Y135.099 Z8.64 F42000
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 0.984916
G1 F2601.941
M204 S6000
G1 X141.041 Y135.139 E.06736
; LINE_WIDTH: 0.956134
G1 F2691.525
G1 X140.694 Y135.18 E.06661
; LINE_WIDTH: 0.917422
G1 F2822.22
G1 X140.48 Y135.203 E.03906
; LINE_WIDTH: 0.871271
G1 F2995.63
G1 X140.267 Y135.226 E.0368
; LINE_WIDTH: 0.824728
G1 F3000
G1 X140.05 Y135.25 E.0351
; LINE_WIDTH: 0.779456
G1 X139.837 Y135.272 E.03213
; LINE_WIDTH: 0.735277
G1 X139.619 Y135.294 E.03071
; LINE_WIDTH: 0.69241
G1 X139.4 Y135.314 E.02873
; LINE_WIDTH: 0.651316
G1 X139.181 Y135.335 E.02667
; LINE_WIDTH: 0.610223
G1 X138.962 Y135.356 E.02461
; LINE_WIDTH: 0.569129
G1 X138.743 Y135.376 E.02254
; LINE_WIDTH: 0.527621
G1 X138.519 Y135.397 E.02087
; LINE_WIDTH: 0.483294
G1 X138.235 Y135.42 E.02365
; LINE_WIDTH: 0.436489
G1 X137.95 Y135.444 E.0206
; LINE_WIDTH: 0.389683
G1 X137.666 Y135.467 E.01755
; LINE_WIDTH: 0.3427
G1 X137.379 Y135.491 E.0146
; LINE_WIDTH: 0.302376
G1 X137.128 Y135.509 E.01048
; LINE_WIDTH: 0.268855
G1 X136.876 Y135.527 E.00855
; LINE_WIDTH: 0.235334
G1 X136.625 Y135.545 E.00662
; WIPE_START
G1 X136.876 Y135.527 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.244 Y131.75 Z8.64 F42000
G1 X112.213 Y121.484 Z8.64
G1 Z8.24
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I5.995 J6.872 E.44658
G1 X122.192 Y135.388 E2.65863
G3 X119.598 Y136.402 I-4.766 J-8.368 E.44621
G1 X130.146 Y125.854 E2.38179
G1 X130.146 Y130.146 E.68528
G1 X119.598 Y119.598 E2.3818
G3 X122.192 Y120.612 I-2.173 J9.382 E.44621
G1 X110.418 Y132.386 E2.65862
G2 X112.213 Y134.516 I7.991 J-4.911 E.44645
; CHANGE_LAYER
; Z_HEIGHT: 8.8
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y133.445 E-.57183
G1 X110.873 Y133.039 E-.18817
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 16/51
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z8.8 I.903 J1.445 P1  F42000
G1 X130.522 Y120.76 Z8.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.559 Y120.76 E.00595
G1 X130.559 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.12363
G3 X121.624 Y136.359 I-7.762 J-11.005 E.35212
G3 X118.037 Y118.816 I-3.818 J-8.357 E5.27472
G3 X122.591 Y120.155 I-.221 J9.165 E.76677
G1 X123.522 Y120.76 E.17717
G1 X130.402 Y120.76 E1.09853
; WIPE_START
G1 X130.559 Y120.76 E-.05975
G1 X130.559 Y122.602 E-.70025
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.259 Y120.236 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.259 Y135.94 E2.50749
G1 X123.729 Y135.94 E1.20226
G3 X119.669 Y137.713 I-6.171 J-8.601 E.71269
G3 X118.066 Y118.117 I-1.861 J-9.711 E5.30017
G3 X122.955 Y119.557 I-.248 J9.861 E.82327
G1 X123.729 Y120.06 E.14734
G1 X131.259 Y120.06 E1.20226
G1 X131.259 Y120.116 E.00905
; WIPE_START
G1 X131.259 Y122.116 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.844 Y121.274 Z9.2 F42000
G1 X143.472 Y120.76 Z9.2
G1 Z8.8
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y120.76 E.62401
G1 X147.38 Y122.431 E.26682
G2 X143.426 Y121.127 I-11.003 J26.718 E.66549
G1 X143.457 Y120.879 E.03989
; WIPE_START
G1 X145.456 Y120.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.843 Y120.276 Z9.2 F42000
G1 X134.799 Y120.06 Z9.2
G1 Z8.8
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E2.12072
G1 X148.08 Y123.517 E.55195
G2 X142.687 Y121.663 I-11.083 J23.473 E.9125
G2 X134.782 Y120.463 I-11.987 J52.316 E1.27776
G1 X134.794 Y120.18 E.04522
; WIPE_START
G1 X136.794 Y120.162 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.93 Y127.12 Z9.2 F42000
G1 X143.425 Y134.874 Z9.2
G1 Z8.8
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X147.38 Y133.568 I-7.011 J-27.867 E.66564
G1 X147.38 Y135.24 E.26703
G1 X143.473 Y135.24 E.62396
G1 X143.441 Y134.993 E.03979
; WIPE_START
G1 X144.937 Y134.452 E-.60462
G1 X145.326 Y134.326 E-.15538
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.743 Y135.197 Z9.2 F42000
G1 X134.782 Y135.537 Z9.2
G1 Z8.8
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X144.119 Y133.963 I-3.506 J-49.264 E1.51436
G2 X148.08 Y132.48 I-6.755 J-24.083 E.67611
G1 X148.08 Y135.94 E.55246
G1 X134.798 Y135.94 E2.12082
G1 X134.787 Y135.657 E.04521
; WIPE_START
G1 X136.67 Y135.359 E-.72463
G1 X136.762 Y135.348 E-.03537
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.34 Y128.11 Z9.2 F42000
G1 X131.958 Y120.995 Z9.2
G1 Z8.8
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.958 Y135.005 E2.23712
G2 X142.596 Y133.639 I-1.674 J-55.116 E1.71519
G2 X146.98 Y132.219 I-6.561 J-27.741 E.73656
G2 X148.78 Y131.28 I-5.919 J-13.544 E.3245
G1 X148.78 Y136.64 E.85583
G1 X123.936 Y136.64 E3.96689
G3 X111.077 Y136.173 I-6.124 J-8.659 E2.20775
G3 X107.231 Y127.506 I6.737 J-8.177 E1.56971
G3 X107.487 Y125.631 I9.425 J.336 E.30273
G3 X111.077 Y119.827 I10.318 J2.368 E1.10954
G3 X118.095 Y117.418 I6.735 J8.191 E1.21035
G3 X123.936 Y119.36 I-.318 J10.711 E.99705
G1 X148.78 Y119.36 E3.96689
G1 X148.78 Y124.718 E.85549
G2 X145.323 Y123.143 I-8.818 J14.779 E.60786
G2 X137.721 Y121.473 I-12.541 J38.947 E1.24467
G2 X132.078 Y120.999 I-8.265 J64.632 E.9044
; WIPE_START
M204 S6000
G1 X132.061 Y122.999 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z9.2 F4000
            G39.3 S1
            G0 Z9.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X131.609 Y120.169 F42000
G1 Z8.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.07797
G1 F2349.146
M204 S6000
G1 X132.931 Y120.198 E.28912
; LINE_WIDTH: 1.11192
G1 F2268.734
G1 X133.691 Y120.222 E.17192
; LINE_WIDTH: 1.14257
G1 F2200.724
G1 X134.441 Y120.245 E.17509
; WIPE_START
G1 X133.691 Y120.222 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.347 Y120.455 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.240534
G1 F3000
M204 S6000
G1 X138.682 Y120.479 E.00924
; LINE_WIDTH: 0.284447
G1 X139.018 Y120.503 E.01261
; LINE_WIDTH: 0.329316
G1 X139.299 Y120.526 E.01349
; LINE_WIDTH: 0.375042
G1 X139.579 Y120.549 E.01633
; LINE_WIDTH: 0.420606
G1 X139.859 Y120.571 E.01925
; LINE_WIDTH: 0.46617
G1 X140.139 Y120.594 E.02217
; LINE_WIDTH: 0.510685
G1 X140.382 Y120.616 E.02176
; LINE_WIDTH: 0.553933
G1 X140.623 Y120.637 E.02388
; LINE_WIDTH: 0.595052
G1 X140.829 Y120.657 E.02244
; LINE_WIDTH: 0.634065
G1 X141.032 Y120.676 E.02398
; LINE_WIDTH: 0.67283
G1 X141.236 Y120.696 E.02579
; LINE_WIDTH: 0.710347
G1 X141.415 Y120.714 E.02429
; LINE_WIDTH: 0.746309
G1 X141.591 Y120.732 E.02528
; LINE_WIDTH: 0.78193
G1 X141.768 Y120.749 E.02672
; LINE_WIDTH: 0.819102
G1 X141.947 Y120.769 E.02878
; LINE_WIDTH: 0.857385
G1 X142.122 Y120.788 E.02956
; LINE_WIDTH: 0.895164
G1 F2903.274
G1 X142.296 Y120.807 E.03108
; LINE_WIDTH: 0.935527
G1 F2759.552
G1 X142.701 Y120.853 E.07581
; LINE_WIDTH: 0.977237
G1 F2625.254
G1 X143.102 Y120.898 E.07883
; WIPE_START
M73 P66 R5
G1 X142.701 Y120.853 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.978 Y121.151 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.242916
G1 F3000
M204 S6000
G1 X145.14 Y121.177 E.00458
; LINE_WIDTH: 0.291033
G1 X145.302 Y121.202 E.00638
; LINE_WIDTH: 0.33915
G1 X145.464 Y121.227 E.00818
; LINE_WIDTH: 0.387267
G1 X145.625 Y121.253 E.00997
; LINE_WIDTH: 0.435384
G1 X145.787 Y121.278 E.01177
; LINE_WIDTH: 0.483502
G1 X145.949 Y121.303 E.01357
; LINE_WIDTH: 0.530823
G1 X146.135 Y121.336 E.01769
; LINE_WIDTH: 0.575333
G1 X146.314 Y121.367 E.01889
; LINE_WIDTH: 0.618998
G1 X146.493 Y121.398 E.0207
; LINE_WIDTH: 0.662662
G1 X146.672 Y121.43 E.02251
; LINE_WIDTH: 0.706326
G1 X146.851 Y121.461 E.02433
; LINE_WIDTH: 0.74999
G1 X147.03 Y121.492 E.02614
; WIPE_START
G1 X146.851 Y121.461 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.956 Y129.093 Z9.2 F42000
G1 X147.03 Y134.507 Z9.2
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.749407
G1 F3000
M204 S6000
G1 X146.833 Y134.541 E.0288
; LINE_WIDTH: 0.702667
G1 X146.635 Y134.576 E.02666
; LINE_WIDTH: 0.655927
G1 X146.438 Y134.611 E.02452
; LINE_WIDTH: 0.609187
G1 X146.24 Y134.646 E.02238
; LINE_WIDTH: 0.561498
G1 X146.035 Y134.682 E.02101
; LINE_WIDTH: 0.513807
G1 X145.884 Y134.706 E.01372
; LINE_WIDTH: 0.468588
G1 X145.733 Y134.73 E.01214
; LINE_WIDTH: 0.423368
G1 X145.582 Y134.753 E.01056
; LINE_WIDTH: 0.378148
G1 X145.431 Y134.777 E.00899
; LINE_WIDTH: 0.332929
G1 X145.281 Y134.801 E.00741
; LINE_WIDTH: 0.287709
G1 X145.13 Y134.825 E.00584
; LINE_WIDTH: 0.242489
G1 X144.979 Y134.848 E.00426
; WIPE_START
G1 X145.13 Y134.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.102 Y135.1 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.981953
G1 F2610.889
M204 S6000
G1 X142.738 Y135.142 E.07206
; LINE_WIDTH: 0.947478
G1 F2719.689
G1 X142.366 Y135.186 E.07055
; LINE_WIDTH: 0.910272
G1 F2847.761
G1 X142.192 Y135.205 E.03165
; LINE_WIDTH: 0.872541
G1 F2990.575
G1 X142.017 Y135.224 E.03014
; LINE_WIDTH: 0.834411
G1 F3000
G1 X141.839 Y135.243 E.02922
; LINE_WIDTH: 0.796778
G1 X141.66 Y135.261 E.02777
; LINE_WIDTH: 0.760021
G1 X141.481 Y135.28 E.02626
; LINE_WIDTH: 0.722706
G1 X141.297 Y135.298 E.02548
; LINE_WIDTH: 0.683459
G1 X141.079 Y135.319 E.02817
; LINE_WIDTH: 0.642743
G1 X140.86 Y135.339 E.02613
; LINE_WIDTH: 0.602026
G1 X140.642 Y135.36 E.0241
; LINE_WIDTH: 0.56131
G1 X140.424 Y135.38 E.02206
; LINE_WIDTH: 0.520193
G1 X140.201 Y135.401 E.0204
; LINE_WIDTH: 0.476325
G1 X139.919 Y135.424 E.02305
; LINE_WIDTH: 0.430022
G1 X139.636 Y135.447 E.02005
; LINE_WIDTH: 0.383719
G1 X139.353 Y135.47 E.01706
; LINE_WIDTH: 0.337243
G1 X139.068 Y135.493 E.01415
; LINE_WIDTH: 0.290113
G1 X138.708 Y135.519 E.014
; LINE_WIDTH: 0.242424
G1 X138.348 Y135.545 E.01007
; WIPE_START
G1 X138.708 Y135.519 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.44 Y135.755 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 1.14265
G1 F2200.551
M204 S6000
G1 X133.692 Y135.778 E.17458
; LINE_WIDTH: 1.11208
G1 F2268.36
G1 X132.935 Y135.802 E.17144
; LINE_WIDTH: 1.07807
G1 F2348.901
G1 X131.609 Y135.831 E.29
; WIPE_START
G1 X132.935 Y135.802 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.317 Y135.331 Z9.2 F42000
G1 X112.208 Y134.521 Z9.2
G1 Z8.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.441 J-7.218 E.4465
G1 X122.192 Y120.612 E2.65862
G2 X119.598 Y119.598 I-4.766 J8.368 E.44621
G1 X129.964 Y129.964 E2.34071
G1 X129.964 Y126.036 E.62717
G1 X119.598 Y136.402 E2.34071
G2 X122.192 Y135.388 I-2.172 J-9.378 E.44621
G1 X110.418 Y123.614 E2.65862
G3 X112.212 Y121.483 I8.028 J4.937 E.44645
; CHANGE_LAYER
; Z_HEIGHT: 9.36
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.554 E-.57161
G1 X110.873 Y122.961 E-.18839
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 17/51
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z9.36 I.191 J1.693 P1  F42000
G1 X130.36 Y120.76 Z9.36
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.377 Y120.76 E.00273
G1 X130.377 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.09459
G3 X121.626 Y136.358 I-7.844 J-11.143 E.3518
G3 X118.008 Y118.815 I-3.82 J-8.357 E5.27067
G3 X122.593 Y120.156 I-.221 J9.263 E.77139
G1 X123.522 Y120.76 E.17689
G1 X130.24 Y120.76 E1.0727
M204 S10000
G1 X131.077 Y120.215 F42000
G1 F3215.099
M204 S6000
G1 X131.077 Y135.94 E2.51084
G1 X123.729 Y135.94 E1.17322
G3 X119.67 Y137.712 I-6.157 J-8.568 E.71248
G3 X118.037 Y118.116 I-1.862 J-9.711 E5.29588
G3 X122.957 Y119.558 I-.221 J9.867 E.82815
G1 X123.729 Y120.06 E.14703
G1 X131.077 Y120.06 E1.17322
G1 X131.077 Y120.095 E.0057
; WIPE_START
G1 X131.077 Y122.095 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.675 Y121.376 Z9.76 F42000
G1 X145.19 Y120.76 Z9.76
G1 Z9.36
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y120.76 E.34968
G1 X147.38 Y121.781 E.16303
G2 X145.144 Y121.127 I-10.496 J31.766 E.37205
G1 X145.176 Y120.879 E.03999
; WIPE_START
G1 X147.173 Y120.771 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.557 Y120.262 Z9.76 F42000
G1 X136.523 Y120.06 Z9.76
G1 Z9.36
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E1.84538
G1 X148.08 Y122.772 E.43313
G2 X141.154 Y121.017 I-12.398 J34.374 E1.14276
G2 X136.507 Y120.463 I-9.444 J59.438 E.74746
G1 X136.518 Y120.18 E.04523
; WIPE_START
G1 X138.518 Y120.159 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.653 Y127.118 Z9.76 F42000
G1 X145.148 Y134.874 Z9.76
G1 Z9.36
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X147.38 Y134.218 I-8.719 J-33.799 E.37167
G1 X147.38 Y135.24 E.16323
G1 X145.195 Y135.24 E.34899
G1 X145.163 Y134.993 E.03979
; WIPE_START
G1 X146.697 Y134.441 E-.61968
G1 X147.048 Y134.326 E-.14032
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.466 Y135.197 Z9.76 F42000
G1 X136.506 Y135.537 Z9.76
G1 Z9.36
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X145.546 Y134.046 I-3.484 J-49.271 E1.46504
G2 X148.08 Y133.226 I-8.022 J-29.11 E.4255
G1 X148.08 Y135.94 E.4334
G1 X136.522 Y135.94 E1.84551
G1 X136.511 Y135.657 E.04522
; WIPE_START
G1 X138.373 Y135.362 E-.71636
G1 X138.487 Y135.348 E-.04364
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.264 Y128.429 Z9.76 F42000
G1 X131.776 Y120.941 Z9.76
G1 Z9.36
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.776 Y135.059 E2.25415
G2 X142.718 Y133.991 I-.479 J-61.498 E1.75766
G2 X147.967 Y132.522 I-6.536 J-33.477 E.8713
G2 X148.78 Y132.184 I-3.405 J-9.334 E.14066
G1 X148.78 Y136.64 E.71151
G1 X123.936 Y136.64 E3.96689
G3 X119.325 Y138.477 I-6.196 J-8.846 E.79974
G3 X111.054 Y136.154 I-1.515 J-10.495 E1.41241
G3 X107.229 Y127.537 I6.764 J-8.16 E1.5601
M73 P67 R5
G3 X111.054 Y119.846 I10.588 J.469 E1.41224
G3 X118.066 Y117.416 I6.752 J8.154 E1.21059
G3 X122.338 Y118.433 I-.227 J10.445 E.70656
G3 X123.936 Y119.36 I-5.271 J10.926 E.29531
G1 X148.78 Y119.36 E3.96689
G1 X148.78 Y123.818 E.71185
G2 X143.643 Y122.205 I-10.89 J25.687 E.86111
G2 X133.336 Y120.98 I-11.909 J56.232 E1.65951
G1 X131.896 Y120.944 E.23002
; WIPE_START
M204 S6000
G1 X131.879 Y122.944 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.76 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.76
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z9.76 F4000
            G39.3 S1
            G0 Z9.76 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X131.427 Y120.146 F42000
G1 Z9.36
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.0222
G1 F2494.404
M204 S6000
G1 X133.36 Y120.17 E.39786
; LINE_WIDTH: 1.05434
G1 F2408.572
G1 X134.004 Y120.184 E.13741
; LINE_WIDTH: 1.08194
G1 F2339.462
G1 X134.64 Y120.198 E.1396
; LINE_WIDTH: 1.11136
G1 F2270.017
G1 X135.407 Y120.221 E.17357
; LINE_WIDTH: 1.14236
G1 F2201.171
G1 X136.165 Y120.245 E.17687
; WIPE_START
G1 X135.407 Y120.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.07 Y120.455 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.238559
G1 F3000
M204 S6000
G1 X140.379 Y120.477 E.00837
; LINE_WIDTH: 0.278524
G1 X140.688 Y120.499 E.0112
; LINE_WIDTH: 0.319833
G1 X140.96 Y120.52 E.01243
; LINE_WIDTH: 0.362365
G1 X141.231 Y120.541 E.01499
; LINE_WIDTH: 0.40778
G1 X141.522 Y120.566 E.01917
; LINE_WIDTH: 0.456098
G1 X141.812 Y120.59 E.0223
; LINE_WIDTH: 0.498027
G1 X142.011 Y120.608 E.01726
; LINE_WIDTH: 0.533487
G1 X142.208 Y120.625 E.01866
; LINE_WIDTH: 0.568748
G1 X142.405 Y120.643 E.02026
; LINE_WIDTH: 0.610107
G1 X142.655 Y120.667 E.028
; LINE_WIDTH: 0.657324
G1 X142.901 Y120.69 E.03037
; LINE_WIDTH: 0.702616
G1 X143.117 Y120.712 E.02883
; LINE_WIDTH: 0.745937
G1 X143.33 Y120.733 E.0305
; LINE_WIDTH: 0.788924
G1 X143.542 Y120.755 E.03259
; LINE_WIDTH: 0.833028
G1 X143.752 Y120.777 E.03425
; LINE_WIDTH: 0.877788
G1 F2969.862
G1 X143.956 Y120.8 E.03558
; LINE_WIDTH: 0.924714
G1 F2796.639
G1 X144.39 Y120.849 E.08021
; LINE_WIDTH: 0.973159
G1 F2637.806
G1 X144.82 Y120.898 E.0842
; WIPE_START
G1 X144.39 Y120.849 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.703 Y121.151 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.23417
G1 F3000
M204 S6000
G1 X146.867 Y121.177 E.00431
; LINE_WIDTH: 0.265357
G1 X147.03 Y121.203 E.00549
; WIPE_START
G1 X146.867 Y121.177 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.958 Y128.809 Z9.76 F42000
G1 X147.03 Y134.798 Z9.76
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.259022
G1 F3000
M204 S6000
G1 X146.816 Y134.832 E.00687
; LINE_WIDTH: 0.228105
G1 X146.701 Y134.848 E.00288
; WIPE_START
G1 X146.816 Y134.832 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.824 Y135.1 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.978978
G1 F2619.932
M204 S6000
G1 X144.435 Y135.145 E.0767
; LINE_WIDTH: 0.938875
G1 F2748.267
G1 X144.04 Y135.191 E.07436
; LINE_WIDTH: 0.895865
G1 F2900.649
G1 X143.836 Y135.213 E.03622
; LINE_WIDTH: 0.851474
G1 F3000
G1 X143.629 Y135.236 E.03478
; LINE_WIDTH: 0.80686
G1 X143.412 Y135.258 E.03407
; LINE_WIDTH: 0.762425
G1 X143.196 Y135.28 E.03187
; LINE_WIDTH: 0.717414
G1 X142.974 Y135.303 E.03041
; LINE_WIDTH: 0.674508
G1 X142.757 Y135.323 E.0276
; LINE_WIDTH: 0.63417
G1 X142.54 Y135.343 E.02559
; LINE_WIDTH: 0.593832
G1 X142.322 Y135.364 E.02358
; LINE_WIDTH: 0.553494
G1 X142.105 Y135.384 E.02158
; LINE_WIDTH: 0.512768
G1 X141.883 Y135.404 E.01992
; LINE_WIDTH: 0.469333
G1 X141.602 Y135.427 E.02248
; LINE_WIDTH: 0.423486
G1 X141.321 Y135.45 E.01952
; LINE_WIDTH: 0.377639
G1 X141.04 Y135.473 E.01657
; LINE_WIDTH: 0.331627
G1 X140.757 Y135.496 E.01371
; LINE_WIDTH: 0.286063
G1 X140.414 Y135.52 E.013
; LINE_WIDTH: 0.241075
G1 X140.072 Y135.545 E.00947
; WIPE_START
G1 X140.414 Y135.52 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.164 Y135.755 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 1.14267
G1 F2200.498
M204 S6000
G1 X135.417 Y135.778 E.17446
; LINE_WIDTH: 1.11216
G1 F2268.188
G1 X134.66 Y135.802 E.17133
; LINE_WIDTH: 1.0828
G1 F2337.357
G1 X134.019 Y135.816 E.1409
; LINE_WIDTH: 1.05483
G1 F2407.311
G1 X133.369 Y135.83 E.13864
; LINE_WIDTH: 1.02233
G1 F2494.043
G1 X131.427 Y135.854 E.39986
; WIPE_START
G1 X133.369 Y135.83 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.052 Y131.546 Z9.76 F42000
G1 X112.212 Y121.482 Z9.76
G1 Z9.36
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I6.272 J7.095 E.44646
G1 X122.192 Y135.388 E2.65861
G3 X119.598 Y136.402 I-4.766 J-8.365 E.44622
G1 X129.782 Y126.218 E2.29963
G1 X129.782 Y129.782 E.56907
G1 X119.598 Y119.598 E2.29963
G3 X122.192 Y120.612 I-2.172 J9.38 E.44622
G1 X110.418 Y132.386 E2.65861
G2 X112.208 Y134.521 I8.232 J-5.082 E.4465
; CHANGE_LAYER
; Z_HEIGHT: 9.92
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y133.446 E-.57161
G1 X110.873 Y133.039 E-.18839
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 18/51
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z9.92 I.914 J1.438 P1  F42000
G1 X130.195 Y120.76 Z9.92
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.195 Y135.24 E2.31222
G1 X123.522 Y135.24 E1.06556
G3 X121.627 Y136.357 I-7.913 J-11.259 E.35155
G3 X117.979 Y118.814 I-3.819 J-8.357 E5.26534
G3 X122.594 Y120.157 I-.187 J9.241 E.77637
G1 X123.522 Y120.76 E.1766
G1 X130.075 Y120.76 E1.0464
M204 S10000
G1 X130.895 Y120.253 F42000
G1 F3215.099
M204 S6000
G1 X130.895 Y135.94 E2.50487
G1 X123.729 Y135.94 E1.14418
G3 X119.672 Y137.712 I-6.143 J-8.536 E.71223
G3 X118.009 Y118.115 I-1.865 J-9.711 E5.29232
G3 X122.958 Y119.559 I-.22 J9.956 E.83282
G1 X123.729 Y120.06 E.14675
G1 X130.895 Y120.06 E1.14418
G1 X130.895 Y120.133 E.01167
; WIPE_START
G1 X130.895 Y122.133 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.499 Y121.481 Z10.32 F42000
G1 X146.914 Y120.76 Z10.32
G1 Z9.92
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y120.76 E.0745
G1 X147.38 Y121.258 E.07965
G1 X146.867 Y121.127 E.08454
G1 X146.899 Y120.879 E.03996
; WIPE_START
G1 X147.38 Y120.76 E-.21246
G1 X147.38 Y121.258 E-.21362
G1 X146.867 Y121.127 E-.22676
G1 X146.899 Y120.879 E-.10717
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.3 Y120.159 Z10.32 F42000
G1 X138.248 Y120.06 Z10.32
G1 Z9.92
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E1.57
G1 X148.08 Y122.188 E.3398
G2 X139.275 Y120.554 I-12.816 J44.533 E1.43216
G2 X138.232 Y120.463 I-3.352 J32.245 E.16729
G1 X138.243 Y120.18 E.04524
; WIPE_START
G1 X140.243 Y120.155 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.375 Y127.116 Z10.32 F42000
M73 P68 R5
G1 X146.866 Y134.875 Z10.32
G1 Z9.92
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X147.38 Y134.739 E.0849
G1 X147.38 Y135.24 E.08012
G1 X146.914 Y135.24 E.07447
G1 X146.882 Y134.994 E.03972
; WIPE_START
G1 X147.38 Y134.739 E-.23951
G1 X147.38 Y135.24 E-.21461
G1 X146.914 Y135.24 E-.19948
G1 X146.882 Y134.994 E-.1064
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.264 Y135.472 Z10.32 F42000
G1 X138.23 Y135.537 Z10.32
G1 Z9.92
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X147.447 Y133.997 I-3.633 J-50.088 E1.4942
G1 X148.08 Y133.81 E.1055
G1 X148.08 Y135.94 E.34016
G1 X138.246 Y135.94 E1.57019
G1 X138.235 Y135.657 E.04522
; WIPE_START
G1 X140.076 Y135.364 E-.70826
G1 X140.211 Y135.348 E-.05174
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.291 Y128.799 Z10.32 F42000
G1 X131.594 Y120.951 Z10.32
G1 Z9.92
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.594 Y135.049 E2.25102
G2 X143.356 Y134.194 I1.236 J-64.312 E1.88561
G2 X148.78 Y132.851 I-6.252 J-36.897 E.89305
G1 X148.78 Y136.64 E.60494
G1 X123.936 Y136.64 E3.9669
G3 X107.354 Y129.689 I-6.123 J-8.649 E3.42792
G3 X118.036 Y117.415 I10.456 J-1.686 E2.96286
G3 X123.936 Y119.36 I-.263 J10.721 E1.00636
G1 X148.78 Y119.36 E3.9669
G1 X148.78 Y123.147 E.60469
G2 X141.084 Y121.462 I-12.518 J38.758 E1.25996
G2 X131.714 Y120.949 I-8.318 J66.121 E1.49954
; WIPE_START
M204 S6000
G1 X131.697 Y122.949 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.32 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.32
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z10.32 F4000
            G39.3 S1
            G0 Z10.32 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X131.245 Y120.158 F42000
G1 Z9.92
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.01161
G1 F2524.031
M204 S6000
G1 X135.077 Y120.17 E.77939
; LINE_WIDTH: 1.05398
G1 F2409.513
G1 X135.717 Y120.184 E.1365
; LINE_WIDTH: 1.08132
G1 F2340.971
G1 X136.349 Y120.197 E.13864
; LINE_WIDTH: 1.11078
G1 F2271.35
G1 X137.124 Y120.221 E.17523
; LINE_WIDTH: 1.14213
G1 F2201.662
G1 X137.89 Y120.245 E.17867
; WIPE_START
G1 X137.124 Y120.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.808 Y120.455 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.236826
G1 F3000
M204 S6000
G1 X142.087 Y120.475 E.00744
; LINE_WIDTH: 0.273325
G1 X142.366 Y120.495 E.00977
; LINE_WIDTH: 0.308811
G1 X142.586 Y120.513 E.0095
; LINE_WIDTH: 0.343224
G1 X142.804 Y120.53 E.01117
; LINE_WIDTH: 0.377548
G1 X143.023 Y120.547 E.01289
; LINE_WIDTH: 0.413814
G1 X143.253 Y120.566 E.01545
; LINE_WIDTH: 0.451931
G1 X143.482 Y120.585 E.01736
; LINE_WIDTH: 0.492155
G1 X143.719 Y120.606 E.02024
; LINE_WIDTH: 0.534457
G1 X143.955 Y120.627 E.02234
; LINE_WIDTH: 0.576564
G1 X144.19 Y120.648 E.02461
; LINE_WIDTH: 0.615583
G1 X144.379 Y120.666 E.02145
; LINE_WIDTH: 0.651294
G1 X144.565 Y120.684 E.02266
; LINE_WIDTH: 0.688429
G1 X144.757 Y120.704 E.02503
; LINE_WIDTH: 0.726951
G1 X144.946 Y120.723 E.02627
; LINE_WIDTH: 0.765146
G1 X145.135 Y120.742 E.02793
; LINE_WIDTH: 0.803342
G1 X145.324 Y120.761 E.02958
; LINE_WIDTH: 0.845289
G1 X145.634 Y120.796 E.05174
; LINE_WIDTH: 0.889389
G1 F2925.071
G1 X145.937 Y120.83 E.05353
; LINE_WIDTH: 0.932931
G1 F2768.367
G1 X146.241 Y120.864 E.05656
; LINE_WIDTH: 0.976472
G1 F2627.599
G1 X146.544 Y120.898 E.05959
; WIPE_START
G1 X146.241 Y120.864 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.403 Y128.494 Z10.32 F42000
G1 X146.543 Y135.1 Z10.32
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.975599
G1 F2630.282
M204 S6000
G1 X146.129 Y135.149 E.08131
; LINE_WIDTH: 0.929372
G1 F2780.541
G1 X145.705 Y135.198 E.07873
; LINE_WIDTH: 0.88316
G1 F2948.954
G1 X145.496 Y135.22 E.0366
; LINE_WIDTH: 0.839605
G1 F3000
G1 X145.287 Y135.241 E.03451
; LINE_WIDTH: 0.79605
M73 P69 R5
G1 X145.078 Y135.263 E.03242
; LINE_WIDTH: 0.752495
G1 X144.869 Y135.285 E.03033
; LINE_WIDTH: 0.708253
G1 X144.653 Y135.307 E.0291
; LINE_WIDTH: 0.665871
G1 X144.437 Y135.327 E.02709
; LINE_WIDTH: 0.62586
G1 X144.22 Y135.347 E.0251
; LINE_WIDTH: 0.585849
G1 X144.003 Y135.367 E.02312
; LINE_WIDTH: 0.545837
G1 X143.787 Y135.387 E.02113
; LINE_WIDTH: 0.505452
G1 X143.566 Y135.408 E.01948
; LINE_WIDTH: 0.462417
G1 X143.286 Y135.431 E.02192
; LINE_WIDTH: 0.417017
G1 X143.006 Y135.453 E.01901
; LINE_WIDTH: 0.371616
G1 X142.727 Y135.476 E.0161
; LINE_WIDTH: 0.326058
G1 X142.445 Y135.499 E.01328
; LINE_WIDTH: 0.282059
G1 X142.12 Y135.522 E.01203
; LINE_WIDTH: 0.239742
G1 X141.795 Y135.545 E.00889
; WIPE_START
G1 X142.12 Y135.522 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.889 Y135.755 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 1.14269
G1 F2200.456
M204 S6000
G1 X137.142 Y135.778 E.17437
; LINE_WIDTH: 1.11222
G1 F2268.051
G1 X136.386 Y135.802 E.17124
; LINE_WIDTH: 1.08295
G1 F2337.003
G1 X135.748 Y135.816 E.14007
; LINE_WIDTH: 1.05511
G1 F2406.596
G1 X135.102 Y135.83 E.13784
; LINE_WIDTH: 1.01184
G1 F2523.367
G1 X131.245 Y135.842 E.78476
; WIPE_START
G1 X133.245 Y135.836 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.627 Y135.36 Z10.32 F42000
G1 X112.208 Y134.521 Z10.32
G1 Z9.92
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.418 Y132.386 I6.439 J-7.215 E.4465
G1 X122.192 Y120.612 E2.6586
G2 X119.598 Y119.598 I-4.766 J8.367 E.44622
G1 X129.6 Y129.6 E2.25854
G1 X129.6 Y126.4 E.51096
G1 X119.598 Y136.402 E2.25855
G2 X122.192 Y135.388 I-2.173 J-9.382 E.44622
G1 X110.418 Y123.614 E2.6586
G3 X112.211 Y121.481 I8.108 J4.994 E.44647
; CHANGE_LAYER
; Z_HEIGHT: 10.48
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.157 Y122.553 E-.57126
G1 X110.873 Y122.961 E-.18874
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 19/51
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z10.48 I.195 J1.693 P1  F42000
G1 X130.013 Y120.76 Z10.48
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.013 Y135.24 E2.31222
G1 X123.521 Y135.24 E1.03651
G3 X121.629 Y136.356 I-8.018 J-11.436 E.35119
G3 X117.952 Y118.813 I-3.821 J-8.356 E5.26141
G3 X122.595 Y120.158 I-.154 J9.217 E.78101
G1 X123.521 Y120.76 E.17637
G1 X129.893 Y120.76 E1.01735
M204 S10000
G1 X130.713 Y120.334 F42000
G1 F3215.099
M204 S6000
G1 X130.713 Y135.94 E2.49184
G1 X123.729 Y135.94 E1.11513
G3 X120.249 Y137.583 I-6.322 J-8.885 E.61763
G3 X117.98 Y118.113 I-2.441 J-9.582 E5.38165
G3 X122.96 Y119.56 I-.186 J9.934 E.83769
G1 X123.729 Y120.06 E.14647
G1 X130.713 Y120.06 E1.11513
G1 X130.713 Y120.214 E.0247
; WIPE_START
G1 X130.713 Y122.214 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.147 Y120.485 Z10.88 F42000
G1 X139.973 Y120.06 Z10.88
G1 Z10.48
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E1.29457
G1 X148.08 Y121.715 E.26431
G2 X139.957 Y120.463 I-12.039 J51.123 E1.3138
G1 X139.968 Y120.18 E.04525
; WIPE_START
G1 X141.968 Y120.15 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.978 Y127.718 Z10.88 F42000
G1 X139.955 Y135.537 Z10.88
G1 Z10.48
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X148.08 Y134.283 I-3.878 J-52.073 E1.31419
G1 X148.08 Y135.94 E.26461
G1 X139.971 Y135.94 E1.29486
G1 X139.959 Y135.657 E.04522
; WIPE_START
G1 X141.778 Y135.366 E-.69993
G1 X141.935 Y135.346 E-.06007
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.42 Y129.192 Z10.88 F42000
G1 X131.413 Y121.003 Z10.88
G1 Z10.48
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.413 Y134.997 E2.23463
G2 X145.039 Y134.201 I2.993 J-65.727 E2.18351
G2 X148.78 Y133.378 I-7.411 J-42.597 E.61177
G1 X148.78 Y136.64 E.52091
G1 X123.936 Y136.64 E3.9669
G3 X107.348 Y129.659 I-6.123 J-8.649 E3.43279
G3 X118.007 Y117.414 I10.462 J-1.655 E2.95342
G3 X123.936 Y119.36 I-.236 J10.726 E1.01102
G1 X148.78 Y119.36 E3.9669
G1 X148.78 Y122.621 E.52065
G2 X140.451 Y121.205 I-12.507 J48.358 E1.35066
G2 X131.532 Y120.998 I-6.096 J70.492 E1.42537
; WIPE_START
M204 S6000
G1 X131.515 Y122.998 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.88 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.88
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z10.88 F4000
            G39.3 S1
            G0 Z10.88 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X131.063 Y120.186 F42000
G1 Z10.48
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.03777
G1 F2452.072
M204 S6000
G1 X132.907 Y120.158 E.3862
; LINE_WIDTH: 1.01249
G1 F2521.526
G1 X136.794 Y120.17 E.79127
; LINE_WIDTH: 1.05365
G1 F2410.353
G1 X137.43 Y120.183 E.13568
; LINE_WIDTH: 1.08074
G1 F2342.386
G1 X138.059 Y120.197 E.13777
; LINE_WIDTH: 1.11023
G1 F2272.598
G1 X138.841 Y120.221 E.17685
; LINE_WIDTH: 1.14194
G1 F2202.083
G1 X139.615 Y120.245 E.18041
; WIPE_START
G1 X138.841 Y120.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.518 Y120.456 Z10.88 F42000
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 0.234959
G1 F3000
M204 S6000
G1 X143.779 Y120.474 E.00685
; LINE_WIDTH: 0.267723
G1 X144.04 Y120.492 E.0088
; LINE_WIDTH: 0.306259
G1 X144.318 Y120.514 E.01183
; LINE_WIDTH: 0.350473
G1 X144.594 Y120.536 E.01456
; LINE_WIDTH: 0.39455
G1 X144.87 Y120.558 E.01734
; LINE_WIDTH: 0.438628
G1 X145.146 Y120.58 E.02013
; LINE_WIDTH: 0.460953
G1 X145.149 Y120.58 E.00025
; LINE_WIDTH: 0.485996
G1 X145.426 Y120.605 E.02322
; LINE_WIDTH: 0.535553
G1 X145.703 Y120.63 E.02636
; LINE_WIDTH: 0.58511
G1 X145.98 Y120.655 E.02951
; LINE_WIDTH: 0.632547
G1 X146.208 Y120.677 E.02671
; LINE_WIDTH: 0.677443
G1 X146.43 Y120.699 E.0284
; LINE_WIDTH: 0.721833
G1 X146.652 Y120.722 E.03066
; LINE_WIDTH: 0.766223
G1 X146.874 Y120.744 E.03293
; LINE_WIDTH: 0.810614
G1 X147.097 Y120.766 E.03519
; LINE_WIDTH: 0.847882
G1 X147.418 Y120.802 E.05369
; LINE_WIDTH: 0.87537
G1 F2979.371
G1 X147.73 Y120.837 E.05414
; WIPE_START
G1 X147.418 Y120.802 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.584 Y128.433 Z10.88 F42000
G1 X147.73 Y135.162 Z10.88
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 0.87421
G1 F2983.953
M204 S6000
G1 X147.218 Y135.221 E.08879
; LINE_WIDTH: 0.836309
G1 F3000
M73 P70 R5
G1 X146.998 Y135.244 E.03609
; LINE_WIDTH: 0.791172
G1 X146.778 Y135.266 E.03382
; LINE_WIDTH: 0.746036
G1 X146.558 Y135.289 E.03154
; LINE_WIDTH: 0.700476
G1 X146.334 Y135.312 E.02979
; LINE_WIDTH: 0.653876
G1 X146.086 Y135.335 E.03036
; LINE_WIDTH: 0.611238
G1 X145.877 Y135.354 E.02352
; LINE_WIDTH: 0.573239
G1 X145.668 Y135.373 E.0217
; LINE_WIDTH: 0.53524
G1 X145.459 Y135.392 E.01988
; LINE_WIDTH: 0.496915
G1 X145.246 Y135.412 E.01835
; LINE_WIDTH: 0.455228
M73 P70 R4
G1 X144.969 Y135.434 E.02128
; LINE_WIDTH: 0.410411
G1 X144.692 Y135.456 E.01844
; LINE_WIDTH: 0.365593
G1 X144.414 Y135.479 E.01559
; LINE_WIDTH: 0.320624
G1 X144.135 Y135.501 E.01282
; LINE_WIDTH: 0.2782
G1 X143.827 Y135.523 E.01113
; LINE_WIDTH: 0.238446
G1 X143.519 Y135.545 E.00833
; WIPE_START
G1 X143.827 Y135.523 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.613 Y135.755 Z10.88 F42000
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 1.14273
G1 F2200.371
M204 S6000
G1 X138.866 Y135.778 E.17428
; LINE_WIDTH: 1.1123
G1 F2267.87
G1 X138.111 Y135.802 E.17115
; LINE_WIDTH: 1.0831
G1 F2336.636
G1 X137.477 Y135.816 E.13926
; LINE_WIDTH: 1.05536
G1 F2405.944
G1 X136.835 Y135.829 E.13706
; LINE_WIDTH: 1.01286
G1 F2520.504
G1 X134.242 Y135.85 E.52804
G1 X132.916 Y135.842 E.27005
; LINE_WIDTH: 1.03767
G1 F2452.339
G1 X131.063 Y135.814 E.38811
; WIPE_START
G1 X132.916 Y135.842 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.37 Y134.701 Z10.88 F42000
G1 X124.656 Y134.593 Z10.88
G1 Z10.48
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X129.068 Y134.593 E.68459
G1 X129.258 Y134.563 E.0299
G1 X129.327 Y134.296 E.04279
G1 X129.327 Y132.153 E.33235
M204 S10000
G1 X129.327 Y127.438 F42000
G1 F3308.823
M204 S6000
G1 X129.327 Y121.704 E.88961
G1 X129.258 Y121.437 E.04279
G1 X129.068 Y121.407 E.0299
G1 X123.418 Y121.407 E.87665
G1 X123.256 Y121.359 E.02623
G1 X122.258 Y120.711 E.18453
G2 X118.408 Y119.487 I-4.47 J7.393 E.63275
G1 X117.407 Y119.468 E.15522
G2 X114.428 Y120.162 I.444 J8.649 E.47714
G1 X113.53 Y120.605 E.15531
G2 X111.204 Y122.591 I4.369 J7.475 E.47704
G1 X110.61 Y123.397 E.15533
G2 X122.266 Y135.284 I7.202 J4.596 E3.56192
G1 X123.256 Y134.641 E.18318
G1 X123.403 Y134.597 E.02385
M204 S10000
G1 X117.893 Y135.894 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X120.629 Y135.371 I-.129 J-8.095 E.44691
G1 X128.718 Y127.282 E1.82667
G1 X128.718 Y124.483 E.44698
M204 S10000
G1 X121.679 Y121.125 F42000
G1 F3215.099
M204 S6000
G1 X110.929 Y131.875 E2.42745
G3 X110.929 Y124.125 I6.894 J-3.875 E1.2933
G1 X121.679 Y134.875 E2.42744
M204 S10000
G1 X117.893 Y120.107 F42000
G1 F3215.099
M204 S6000
G1 X117.935 Y120.108 E.00661
G3 X120.629 Y120.629 I-.314 J8.849 E.43992
G1 X128.718 Y128.718 E1.82667
G1 X128.718 Y128.908 E.0304
G1 X128.813 Y128.813 E.02149
G1 X129.418 Y129.418 E.13656
G1 X129.418 Y131.263 E.29462
G1 X128.743 Y130.588 E.15236
; CHANGE_LAYER
; Z_HEIGHT: 11.04
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X129.418 Y131.263 E-.36259
G1 X129.418 Y130.217 E-.39741
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 20/51
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change
M106 S191.25
; OBJECT_ID: 15
M204 S10000
G17
G3 Z11.04 I1.702 J.074 P1  F42000
G1 X129.831 Y120.76 Z11.04
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.831 Y135.24 E2.31222
G1 X123.521 Y135.24 E1.00748
G3 X121.63 Y136.356 I-8.246 J-11.821 E.35098
G3 X117.923 Y118.811 I-3.821 J-8.356 E5.25693
G3 X122.597 Y120.159 I-.12 J9.198 E.78615
G1 X123.521 Y120.76 E.17602
G1 X129.711 Y120.76 E.98832
M204 S10000
G1 X130.531 Y120.487 F42000
G1 F3215.099
M204 S6000
G1 X130.531 Y135.94 E2.46754
G1 X123.729 Y135.94 E1.08609
G3 X120.251 Y137.583 I-6.322 J-8.885 E.61741
G3 X117.95 Y118.112 I-2.442 J-9.583 E5.37716
G3 X122.962 Y119.561 I-.151 J9.914 E.84286
G1 X123.729 Y120.06 E.14615
G1 X130.531 Y120.06 E1.08609
G1 X130.531 Y120.367 E.049
; WIPE_START
G1 X130.531 Y122.367 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.005 Y120.823 Z11.44 F42000
G1 X141.698 Y120.06 Z11.44
G1 Z11.04
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E1.0191
G1 X148.08 Y121.337 E.2039
G2 X141.682 Y120.463 I-10.688 J54.402 E1.03173
G1 X141.693 Y120.18 E.04527
; WIPE_START
G1 X143.693 Y120.142 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.703 Y127.71 Z11.44 F42000
G1 X141.679 Y135.537 Z11.44
G1 Z11.04
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X148.08 Y134.664 I-4.273 J-55.198 E1.03222
G1 X148.08 Y135.94 E.20385
G1 X141.695 Y135.94 E1.01956
G1 X141.684 Y135.657 E.04523
; WIPE_START
G1 X143.481 Y135.369 E-.69187
G1 X143.659 Y135.347 E-.06813
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.638 Y129.599 Z11.44 F42000
G1 X131.231 Y121.117 Z11.44
G1 Z11.04
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.231 Y134.883 E2.19794
G1 X131.493 Y134.901 E.04208
G1 X131.979 Y134.934 E.07777
G2 X145.654 Y134.381 I4.133 J-67.115 E2.18907
G2 X148.78 Y133.803 I-13.319 J-80.811 E.50762
G1 X148.78 Y136.64 E.45303
G1 X123.936 Y136.64 E3.9669
G3 X119.239 Y138.491 I-6.207 J-8.865 E.81366
G3 X107.343 Y129.629 I-1.434 J-10.491 E2.62422
G3 X117.978 Y117.413 I10.469 J-1.623 E2.94397
G3 X123.936 Y119.36 I-.21 J10.733 E1.01569
G1 X148.78 Y119.36 E3.9669
G1 X148.78 Y122.198 E.45321
G2 X137.227 Y120.948 I-12.056 J57.414 E1.85857
G2 X131.979 Y121.066 I-.987 J72.918 E.83836
G1 X131.493 Y121.099 E.07767
G1 X131.35 Y121.109 E.02293
; WIPE_START
M204 S6000
G1 X131.333 Y123.109 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11.44 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11.44
G1 X0 Y128 F18000 ; move to safe pos
M106 S255
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z11.44 F4000
            G39.3 S1
            G0 Z11.44 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X130.881 Y120.25 F42000
G1 Z11.04
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.14236
G1 F2201.177
M204 S6000
M73 P71 R4
G1 X132.035 Y120.21 E.26947
; LINE_WIDTH: 1.10438
G1 F2286.119
G1 X132.694 Y120.194 E.14783
; LINE_WIDTH: 1.07215
G1 F2363.511
G1 X133.342 Y120.178 E.14092
; LINE_WIDTH: 1.03619
G1 F2456.298
G1 X134.647 Y120.158 E.27275
; LINE_WIDTH: 1.0124
G1 F2521.793
G1 X138.511 Y120.17 E.78652
; LINE_WIDTH: 1.05329
G1 F2411.282
G1 X139.144 Y120.183 E.13481
; LINE_WIDTH: 1.08013
G1 F2343.861
G1 X139.768 Y120.197 E.13686
; LINE_WIDTH: 1.10968
G1 F2273.868
G1 X140.559 Y120.221 E.17853
; LINE_WIDTH: 1.14171
G1 F2202.565
G1 X141.34 Y120.244 E.18223
; WIPE_START
G1 X140.559 Y120.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.243 Y120.456 Z11.44 F42000
G1 Z11.04
G1 E.8 F1800
; LINE_WIDTH: 0.233092
G1 F3000
M204 S6000
G1 X145.478 Y120.472 E.00607
; LINE_WIDTH: 0.262121
G1 X145.713 Y120.488 E.00763
; LINE_WIDTH: 0.298519
G1 X145.99 Y120.51 E.01129
; LINE_WIDTH: 0.342224
G1 X146.265 Y120.532 E.01397
; LINE_WIDTH: 0.385802
G1 X146.54 Y120.553 E.01671
; LINE_WIDTH: 0.42938
G1 X146.815 Y120.575 E.01945
; LINE_WIDTH: 0.471943
G1 X147.122 Y120.603 E.02478
; LINE_WIDTH: 0.513033
G1 X147.426 Y120.63 E.02737
; LINE_WIDTH: 0.553896
G1 X147.73 Y120.657 E.03022
; WIPE_START
G1 X147.426 Y120.63 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.584 Y128.261 Z11.44 F42000
G1 X147.73 Y135.342 Z11.44
G1 Z11.04
G1 E.8 F1800
; LINE_WIDTH: 0.557526
G1 F3000
M204 S6000
G1 X147.465 Y135.366 E.02661
; LINE_WIDTH: 0.523024
G1 X147.199 Y135.391 E.02451
; LINE_WIDTH: 0.488282
G1 X146.93 Y135.415 E.02271
; LINE_WIDTH: 0.448434
G1 X146.654 Y135.437 E.02076
; LINE_WIDTH: 0.404029
G1 X146.377 Y135.459 E.01795
; LINE_WIDTH: 0.359623
G1 X146.101 Y135.482 E.01514
; LINE_WIDTH: 0.315072
G1 X145.823 Y135.504 E.01241
; LINE_WIDTH: 0.274195
G1 X145.533 Y135.524 E.01021
; LINE_WIDTH: 0.237112
G1 X145.243 Y135.545 E.00776
; WIPE_START
G1 X145.533 Y135.524 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.337 Y135.755 Z11.44 F42000
G1 Z11.04
G1 E.8 F1800
; LINE_WIDTH: 1.14274
G1 F2200.36
M204 S6000
G1 X140.591 Y135.778 E.17417
; LINE_WIDTH: 1.11235
G1 F2267.742
G1 X139.836 Y135.802 E.17104
; LINE_WIDTH: 1.08324
G1 F2336.294
G1 X139.206 Y135.815 E.13843
; LINE_WIDTH: 1.05562
G1 F2405.267
G1 X138.568 Y135.829 E.13627
; LINE_WIDTH: 1.01289
G1 F2520.419
G1 X135.991 Y135.85 E.52493
G1 X134.672 Y135.842 E.26852
; LINE_WIDTH: 1.03571
G1 F2457.574
G1 X133.357 Y135.822 E.27488
; LINE_WIDTH: 1.07172
G1 F2364.584
G1 X132.703 Y135.806 E.14197
; LINE_WIDTH: 1.10408
G1 F2286.816
G1 X132.04 Y135.79 E.14895
; LINE_WIDTH: 1.14224
G1 F2201.439
G1 X130.881 Y135.75 E.27041
; WIPE_START
G1 X132.04 Y135.79 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.836 Y128.862 Z11.44 F42000
G1 X128.813 Y128.813 Z11.44
G1 Z11.04
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X129.236 Y129.236 E.09549
M204 S10000
G1 X109.956 Y132.194 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.8046
; LAYER_HEIGHT: 0.8
G1 F1800
M204 S6000
G1 X111.939 Y134.176 E.58071
G2 X115.019 Y136.048 I5.907 J-6.249 E.75239
G1 X109.754 Y130.783 E1.54248
G3 X109.371 Y129.192 I8.559 J-2.901 E.33958
G1 X116.611 Y136.432 E2.12109
G2 X117.907 Y136.519 I1.13 J-7.143 E.26936
G1 X109.289 Y127.901 E2.52467
G3 X109.375 Y126.778 I9.215 J.137 E.23346
G1 X119.026 Y136.429 E2.82742
G2 X120.027 Y136.222 I-1.377 J-9.174 E.21193
G1 X109.582 Y125.777 E3.06011
G3 X109.884 Y124.87 I27.599 J8.692 E.19796
G1 X120.936 Y135.922 E3.23781
G2 X121.765 Y135.542 I-2.747 J-7.092 E.18899
G1 X110.265 Y124.042 E3.3691
G3 X110.715 Y123.283 I7.739 J4.073 E.18282
G1 X122.522 Y135.091 E3.45931
G1 X123.255 Y134.615 E.18098
G1 X111.227 Y122.587 E3.52378
G3 X111.805 Y121.956 I5.65 J4.597 E.17731
G1 X123.987 Y134.139 E3.56905
G1 X124.452 Y133.836 E.11499
G1 X124.786 Y134.571 E.16707
G1 X125.628 Y134.571 E.17442
G1 X112.442 Y121.385 E3.86297
G3 X113.139 Y120.874 I6.352 J7.926 E.17917
G1 X126.836 Y134.571 E4.01282
G1 X128.045 Y134.571 E.25037
G1 X113.904 Y120.429 E4.14295
G3 X114.738 Y120.055 I6.213 J12.75 E.1895
G1 X129.161 Y134.478 E4.22549
G1 X129.161 Y133.27 E.25037
G1 X115.652 Y119.761 E3.95769
G3 X116.661 Y119.561 I2.15 J8.223 E.21322
G1 X126.815 Y129.715 E2.97479
G1 X127.42 Y129.111 E.17704
G1 X117.792 Y119.484 E2.82055
G3 X119.1 Y119.583 I.063 J7.819 E.2721
G1 X128.024 Y128.507 E2.61435
G1 X128.628 Y127.902 E.17704
G1 X120.726 Y120.001 E2.31502
G3 X121.243 Y120.208 I-1.48 J4.437 E.11551
G3 X122.248 Y120.731 I-3.369 J7.702 E.23485
G1 X123.323 Y121.429 E.26548
G1 X123.364 Y121.429 E.00848
G1 X129.161 Y127.227 E1.69847
G1 X129.161 Y126.018 E.25037
G1 X124.572 Y121.429 E1.34439
G1 X125.781 Y121.429 E.25037
G1 X129.161 Y124.81 E.9903
G1 X129.161 Y123.601 E.25037
G1 X126.989 Y121.429 E.63622
G1 X128.198 Y121.429 E.25037
G1 X129.544 Y122.775 E.3942
M106 S191.25
; CHANGE_LAYER
; Z_HEIGHT: 11.6
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F1800
G1 X128.198 Y121.429 E-.72309
G1 X128.101 Y121.429 E-.03691
; WIPE_END
G1 E-.04
; layer num/total_layer_count: 21/51
; update layer progress
M73 L21
M991 S0 P20 ;notify layer change
M106 S196.35
; OBJECT_ID: 15
M204 S10000
G17
G3 Z11.6 I.677 J1.564 P1  F42000
G1 X129.649 Y120.76 Z11.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X129.649 Y135.24 E2.31222
G1 X126.014 Y135.24 E.5804
G1 X124.202 Y134.68 E.30283
G3 X122.598 Y135.841 I-10.818 J-13.267 E.31631
G3 X118.456 Y118.834 I-4.79 J-7.842 E5.51743
G3 X123.294 Y120.631 I-.658 J9.181 E.83528
G1 X124.195 Y121.322 E.1812
G1 X126.014 Y120.76 E.30406
G1 X129.529 Y120.76 E.56125
M204 S10000
G1 X130.349 Y120.666 F42000
G1 F3215.099
M204 S6000
M73 P72 R4
G1 X130.349 Y135.363 E2.34686
G1 X132.344 Y135.539 E.31975
G1 X132.326 Y135.94 E.06417
G1 X125.908 Y135.94 E1.02472
G1 X124.339 Y135.455 E.26236
G3 X120.818 Y137.42 I-7.022 J-8.448 E.64741
G3 X118.506 Y118.135 I-3.009 J-9.42 E5.56032
G3 X123.713 Y120.07 I-.707 J9.878 E.89894
G1 X124.334 Y120.546 E.12501
G1 X125.908 Y120.06 E.26315
G1 X132.325 Y120.06 E1.02455
G1 X132.342 Y120.461 E.06416
G1 X130.44 Y120.629 E.30501
; WIPE_START
G1 X130.427 Y122.629 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.915 Y121.149 Z12 F42000
G1 X143.423 Y120.06 Z12
G1 Z11.6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E.74358
G1 X148.08 Y121.024 E.1539
G2 X143.407 Y120.463 I-9.368 J58.334 E.75167
G1 X143.419 Y120.18 E.04528
; WIPE_START
G1 X145.418 Y120.128 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.428 Y127.696 Z12 F42000
G1 X143.403 Y135.537 Z12
G1 Z11.6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X148.08 Y134.976 I-4.643 J-58.463 E.75238
G1 X148.08 Y135.94 E.15396
G1 X143.419 Y135.94 E.74422
G1 X143.408 Y135.657 E.04523
; WIPE_START
G1 X145.184 Y135.371 E-.68376
G1 X145.384 Y135.347 E-.07624
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.936 Y130.001 Z12 F42000
G1 X131.049 Y121.278 Z12
G1 Z11.6
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.049 Y134.722 E2.14677
G1 X131.312 Y134.745 E.04215
G1 X131.909 Y134.798 E.0958
G1 X131.98 Y134.804 E.01127
G1 X132.577 Y134.857 E.0958
M73 P73 R4
G1 X133.719 Y134.934 E.18268
G2 X148.407 Y134.214 I4.152 J-65.495 E2.35319
G1 X148.78 Y134.146 E.06047
G1 X148.78 Y136.64 E.3982
G1 X125.803 Y136.64 E3.66889
G1 X124.475 Y136.23 E.22188
G3 X118.556 Y117.437 I-6.666 J-8.229 E6.58293
G3 X124.473 Y119.771 I-.793 J10.678 E1.03121
G1 X125.803 Y119.36 E.22225
G1 X148.78 Y119.36 E3.66889
G1 X148.78 Y121.854 E.39822
G2 X135.126 Y120.994 I-10.837 J63.241 E2.18864
G2 X133.713 Y121.066 I1.164 J36.875 E.22601
G1 X132.568 Y121.144 E.18318
G1 X131.97 Y121.197 E.09581
G1 X131.909 Y121.202 E.00982
G1 X131.312 Y121.255 E.09581
G1 X131.168 Y121.267 E.02299
; WIPE_START
M204 S6000
G1 X131.15 Y123.267 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z12
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z12 F4000
            G39.3 S1
            G0 Z12 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X129.369 Y122.481 F42000
G1 Z11.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.832777
G1 F3157.452
M204 S6000
G1 X128.242 Y121.354 E.2591
G1 X127.234 Y121.354 E.16385
G1 X128.387 Y122.507 E.26492
G1 X127.617 Y122.745 E.13101
G1 X126.227 Y121.354 E.31963
G1 X126.104 Y121.354 E.01997
G1 X125.428 Y121.563 E.11505
G1 X126.847 Y122.982 E.32629
G1 X126.077 Y123.22 E.13101
G1 X124.658 Y121.801 E.32629
G1 X124.079 Y121.98 E.0986
G1 X123.047 Y121.198 E.2104
G1 X125.307 Y123.458 E.5196
G1 X124.537 Y123.696 E.13101
G1 X120.782 Y119.941 E.86353
G2 X119.387 Y119.554 I-2.822 J7.465 E.23566
G1 X123.767 Y123.934 E1.00721
G1 X122.998 Y124.172 E.13101
G1 X118.246 Y119.42 E1.09259
G2 X117.245 Y119.427 I-.435 J9.721 E.16283
G1 X122.228 Y124.41 E1.14575
G1 X121.458 Y124.648 E.13101
G1 X116.342 Y119.532 E1.17633
G2 X115.521 Y119.719 I1.234 J7.314 E.13695
G1 X120.967 Y125.164 E1.25213
G1 X120.967 Y126.172 E.16385
G1 X114.761 Y119.966 E1.427
G2 X114.056 Y120.269 I2.191 J6.055 E.12477
G1 X120.967 Y127.18 E1.58896
G1 X120.967 Y128.188 E.16385
G1 X113.401 Y120.622 E1.73952
G2 X112.794 Y121.022 I3.038 J5.278 E.11837
G1 X120.967 Y129.195 E1.87927
G1 X120.967 Y130.203 E.16385
G1 X112.228 Y121.464 E2.00943
G2 X111.706 Y121.95 I3.606 J4.392 E.11601
G1 X123.911 Y134.155 E2.80632
G1 X123.337 Y134.589 E.11696
G1 X111.224 Y122.476 E2.78529
G2 X110.787 Y123.047 I7.214 J5.986 E.11689
G1 X122.758 Y135.017 E2.75256
G3 X122.146 Y135.414 I-3.057 J-4.048 E.11858
G1 X110.392 Y123.659 E2.7028
G2 X110.041 Y124.317 I9.584 J5.53 E.12114
G1 X121.487 Y135.763 E2.63187
G3 X120.777 Y136.06 I-3.764 J-8.008 E.12528
G1 X109.746 Y125.029 E2.53644
G2 X109.501 Y125.792 I8.825 J3.247 E.13036
G1 X120.013 Y136.304 E2.41705
G3 X119.181 Y136.48 I-2.399 J-9.291 E.13829
G1 X109.324 Y126.623 E2.26647
G2 X109.227 Y127.533 I10.33 J1.562 E.14895
G1 X118.272 Y136.579 E2.07982
G3 X117.26 Y136.574 I-.466 J-9.151 E.16466
G1 X109.232 Y128.546 E1.846
G2 X109.386 Y129.708 I8.646 J-.554 E.19067
G1 X116.096 Y136.418 E1.54294
G3 X114.667 Y135.997 I1.247 J-6.867 E.24261
G1 X109.809 Y131.139 E1.11717
G2 X111.478 Y133.816 I8.061 J-3.167 E.51589
G1 X113.409 Y135.746 E.44384
M204 S10000
G1 X121.933 Y131.17 F42000
G1 F3157.452
M204 S6000
G1 X125.098 Y134.335 E.72781
G1 X126.104 Y134.646 E.17114
G1 X126.417 Y134.646 E.05087
G1 X123.868 Y132.097 E.58596
G1 X125.327 Y132.548 E.24819
G1 X127.425 Y134.646 E.48233
G1 X128.432 Y134.646 E.16385
G1 X126.785 Y132.999 E.3787
G1 X128.244 Y133.449 E.24819
G1 X129.369 Y134.574 E.25873
M204 S10000
G1 X127.129 Y132.372 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X124.454 Y131.546 E.44698
G1 X129.054 Y126.946 E1.0387
G1 X129.054 Y129.054 E.33664
G1 X124.454 Y124.454 E1.0387
G1 X121.78 Y125.281 E.44698
; WIPE_START
G1 X123.691 Y124.69 E-.76
; WIPE_END
M73 P74 R4
G1 E-.04 F1800
M204 S10000
G1 X130.533 Y121.309 Z12 F42000
G1 X132.683 Y120.247 Z12
G1 Z11.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.13895
G1 F2208.55
M204 S6000
G1 X133.79 Y120.209 E.25747
; LINE_WIDTH: 1.10282
G1 F2289.751
G1 X134.445 Y120.193 E.14671
; LINE_WIDTH: 1.07103
G1 F2366.293
G1 X135.089 Y120.177 E.13989
; LINE_WIDTH: 1.03556
G1 F2457.978
G1 X136.388 Y120.158 E.27122
; LINE_WIDTH: 1.01231
G1 F2522.057
G1 X140.228 Y120.17 E.78165
; LINE_WIDTH: 1.05296
G1 F2412.135
G1 X140.857 Y120.183 E.13394
; LINE_WIDTH: 1.07954
G1 F2345.317
G1 X141.478 Y120.196 E.13594
; LINE_WIDTH: 1.10911
G1 F2275.19
G1 X142.276 Y120.22 E.18025
; LINE_WIDTH: 1.14151
G1 F2203.012
G1 X143.066 Y120.244 E.18409
; WIPE_START
G1 X142.276 Y120.22 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.969 Y120.456 Z12 F42000
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 0.231245
G1 F3000
M204 S6000
G1 X147.178 Y120.47 E.00532
; LINE_WIDTH: 0.256581
G1 X147.388 Y120.484 E.00654
; LINE_WIDTH: 0.288819
G1 X147.73 Y120.511 E.01321
; WIPE_START
G1 X147.388 Y120.484 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.562 Y128.115 Z12 F42000
G1 X147.73 Y135.489 Z12
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 0.297503
G1 F3000
M204 S6000
G1 X147.512 Y135.507 E.00888
; LINE_WIDTH: 0.270235
G1 X147.239 Y135.526 E.00934
; LINE_WIDTH: 0.235791
G1 X146.967 Y135.544 E.0072
; WIPE_START
G1 X147.239 Y135.526 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.062 Y135.755 Z12 F42000
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 1.14278
G1 F2200.276
M204 S6000
G1 X142.316 Y135.778 E.17409
; LINE_WIDTH: 1.11243
G1 F2267.561
G1 X141.561 Y135.802 E.17095
; LINE_WIDTH: 1.0834
G1 F2335.916
G1 X140.935 Y135.815 E.13761
; LINE_WIDTH: 1.05589
G1 F2404.577
G1 X140.301 Y135.829 E.13548
; LINE_WIDTH: 1.01291
G1 F2520.339
G1 X136.43 Y135.843 E.78851
; LINE_WIDTH: 1.03465
G1 F2460.424
G1 X135.119 Y135.823 E.2734
; LINE_WIDTH: 1.06997
G1 F2368.948
G1 X134.47 Y135.807 E.14082
; LINE_WIDTH: 1.10174
G1 F2292.269
G1 X133.811 Y135.791 E.14768
; LINE_WIDTH: 1.13843
G1 F2209.66
G1 X132.685 Y135.753 E.26176
; CHANGE_LAYER
; Z_HEIGHT: 12.16
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2209.66
G1 X133.811 Y135.791 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 22/51
; update layer progress
M73 L22
M991 S0 P21 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z12.16 I1.624 J-.516 P1  F42000
G1 X129.467 Y122.129 Z12.16
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X129.467 Y133.871 E1.87497
G1 X120.925 Y131.231 E1.42765
G1 X120.925 Y124.769 E1.03197
G1 X129.352 Y122.164 E1.40848
; WIPE_START
G1 X129.372 Y124.164 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.167 Y121.36 Z12.56 F42000
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X130.167 Y134.82 E2.14922
G1 X120.225 Y131.748 E1.66156
G1 X120.225 Y124.252 E1.19682
G1 X130.167 Y121.18 E1.66156
G1 X130.167 Y121.24 E.00956
; WIPE_START
G1 X130.167 Y123.24 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.476 Y130.515 Z12.56 F42000
G1 X134.071 Y135.539 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X134.054 Y135.94 E.06419
G1 X130.771 Y135.94 E.52428
G1 X130.675 Y135.652 E.04841
G1 X131.226 Y135.242 E.10962
G1 X131.746 Y135.31 E.08369
G2 X133.952 Y135.529 I6.742 J-56.543 E.35405
; WIPE_START
G1 X134.054 Y135.94 E-.16095
G1 X132.478 Y135.94 E-.59905
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.103 Y128.317 Z12.56 F42000
G1 X131.729 Y120.7 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.244 Y120.755 E.07797
G1 X130.695 Y120.348 E.10916
G1 X130.79 Y120.06 E.04846
G1 X134.051 Y120.06 E.52075
G1 X134.069 Y120.461 E.06418
G2 X133 Y120.558 I5.234 J64.03 E.17132
G1 X131.848 Y120.687 E.18509
; WIPE_START
G1 X131.244 Y120.755 E-.23116
G1 X130.695 Y120.348 E-.25979
G1 X130.79 Y120.06 E-.11532
G1 X131.195 Y120.06 E-.15373
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.827 Y120.06 Z12.56 F42000
G1 X145.158 Y120.06 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E.46663
G1 X148.08 Y120.772 E.11374
G2 X145.141 Y120.463 I-13.173 J110.957 E.47186
G1 X145.153 Y120.18 E.04521
; WIPE_START
G1 X147.151 Y120.098 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.619 Y127.716 Z12.56 F42000
G1 X148.08 Y135.232 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E.11315
G1 X145.144 Y135.94 E.46887
G1 X145.128 Y135.537 E.0644
G2 X147.961 Y135.246 I-5.445 J-67.016 E.45485
; WIPE_START
G1 X148.08 Y135.94 E-.26749
G1 X146.784 Y135.94 E-.49251
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.178 Y130.761 Z12.56 F42000
G1 X131.13 Y121.476 Z12.56
G1 Z12.16
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.867 Y121.51 E.04234
G1 X130.867 Y134.49 E2.07266
G1 X131.13 Y134.524 E.04234
G1 X131.828 Y134.615 E.11242
G1 X132.424 Y134.679 E.0958
G1 X132.487 Y134.686 E.00999
G1 X133.083 Y134.75 E.0958
G1 X133.681 Y134.802 E.0958
G1 X133.756 Y134.809 E.01205
G1 X134.354 Y134.861 E.0958
G1 X135.468 Y134.936 E.17825
G2 X148.78 Y134.426 I4.1 J-67.029 E2.13072
G1 X148.78 Y136.64 E.35354
G1 X127.526 Y136.64 E3.39369
G1 X124.932 Y135.838 E.43357
G3 X118.557 Y117.437 I-7.122 J-7.838 E6.67912
M73 P75 R4
G3 X124.934 Y120.161 I-.799 J10.697 E1.12747
G1 X127.526 Y119.36 E.43321
G1 X148.78 Y119.36 E3.39369
G1 X148.78 Y121.573 E.35334
G2 X135.452 Y121.065 I-9.214 J66.679 E2.13315
G1 X134.329 Y121.141 E.17974
G1 X133.731 Y121.193 E.09581
G1 X133.666 Y121.199 E.0105
G1 X133.068 Y121.251 E.09581
G1 X132.472 Y121.316 E.09581
G1 X132.42 Y121.321 E.00831
G1 X131.823 Y121.386 E.09581
G1 X131.249 Y121.46 E.09255
; WIPE_START
M204 S6000
G1 X130.867 Y121.51 E-.14635
G1 X130.867 Y123.125 E-.61365
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12.56 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z12.56
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z12.56 F4000
            G39.3 S1
            G0 Z12.56 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X128.533 Y120.939 F42000
G1 Z12.16
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.846107
G1 F3099.473
M204 S6000
G1 X129.776 Y120.554 E.21559
G1 X129.127 Y120.073 E.13386
G1 X128.557 Y120.073 E.09446
G1 X128.544 Y120.82 E.12369
; WIPE_START
G1 X128.557 Y120.073 E-.28377
G1 X129.127 Y120.073 E-.21672
G1 X129.676 Y120.48 E-.2595
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.41 Y120.247 Z12.56 F42000
G1 Z12.16
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.138
G1 F2210.609
M204 S6000
G1 X135.545 Y120.208 E.26379
; LINE_WIDTH: 1.10126
G1 F2293.387
G1 X136.196 Y120.193 E.1457
; LINE_WIDTH: 1.06989
G1 F2369.143
G1 X136.837 Y120.177 E.13898
; LINE_WIDTH: 1.03494
G1 F2459.659
G1 X138.127 Y120.158 E.26927
; LINE_WIDTH: 1.01221
G1 F2522.321
G1 X141.944 Y120.17 E.77694
; LINE_WIDTH: 1.05261
G1 F2413.053
G1 X142.57 Y120.183 E.13319
; LINE_WIDTH: 1.07895
G1 F2346.759
G1 X143.188 Y120.196 E.13515
; LINE_WIDTH: 1.1087
G1 F2276.129
G1 X143.998 Y120.22 E.1829
; LINE_WIDTH: 1.14168
G1 F2202.64
G1 X144.8 Y120.245 E.18695
; WIPE_START
G1 X143.998 Y120.22 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.385 Y127.843 Z12.56 F42000
G1 X144.786 Y135.755 Z12.56
G1 Z12.16
G1 E.8 F1800
; LINE_WIDTH: 1.14281
G1 F2200.212
M204 S6000
G1 X144.04 Y135.778 E.17408
; LINE_WIDTH: 1.11248
G1 F2267.447
G1 X143.286 Y135.802 E.17094
; LINE_WIDTH: 1.08352
G1 F2335.612
G1 X142.664 Y135.815 E.13672
; LINE_WIDTH: 1.05615
G1 F2403.914
G1 X142.034 Y135.829 E.13462
; LINE_WIDTH: 1.01295
G1 F2520.24
G1 X138.184 Y135.843 E.78411
; LINE_WIDTH: 1.0336
G1 F2463.253
G1 X136.883 Y135.824 E.27117
; LINE_WIDTH: 1.06816
G1 F2373.466
G1 X136.237 Y135.808 E.13985
; LINE_WIDTH: 1.09939
G1 F2297.765
G1 X135.581 Y135.793 E.14658
; LINE_WIDTH: 1.13704
G1 F2212.697
G1 X134.412 Y135.753 E.27126
; WIPE_START
G1 X135.581 Y135.793 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.505 Y135.053 Z12.56 F42000
G1 Z12.16
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.846117
G1 F3099.43
M204 S6000
G1 X128.568 Y135.584 E.08858
G1 X128.555 Y135.927 E.05695
G1 X129.113 Y135.927 E.09232
G1 X129.764 Y135.442 E.13457
G1 X128.619 Y135.088 E.19852
M204 S10000
G1 X126.862 Y136.142 F42000
; FEATURE: Top surface
; LINE_WIDTH: 0.834577
G1 F3149.496
M204 S2000
G1 X127.807 Y135.197 E.21782
G2 X127.705 Y134.682 I-3.839 J.488 E.08562
G1 X127.404 Y134.589 E.05135
G1 X126.342 Y135.651 E.24495
G1 X125.57 Y135.413 E.13168
G1 X126.632 Y134.35 E.24495
G1 X125.861 Y134.112 E.13168
G1 X124.798 Y135.174 E.24495
G1 X124.519 Y135.409 E.05943
G3 X121.808 Y137.154 I-6.809 J-7.598 E.52767
G1 X125.089 Y133.873 E.75623
G1 X124.317 Y133.635 E.13168
G1 X120.265 Y137.687 E.93399
G3 X119.023 Y137.918 I-2.797 J-11.553 E.20601
G1 X123.545 Y133.396 E1.04235
G1 X122.773 Y133.158 E.13168
G1 X117.938 Y137.993 E1.11467
G3 X116.966 Y137.955 I.04 J-13.429 E.15862
G1 X122.002 Y132.919 E1.16086
G1 X121.23 Y132.681 E.13167
G1 X116.07 Y137.841 E1.18948
G3 X115.244 Y137.656 I1.115 J-6.937 E.13802
G1 X120.458 Y132.442 E1.20195
G1 X119.686 Y132.204 E.13167
G1 X114.47 Y137.42 E1.20244
G3 X113.748 Y137.131 I4.919 J-13.342 E.1267
G1 X119.63 Y131.25 E1.35585
G1 X119.63 Y130.239 E.16468
G1 X113.072 Y136.798 E1.51181
G3 X112.434 Y136.425 I2.767 J-5.461 E.12044
G1 X119.63 Y129.229 E1.65873
G1 X119.63 Y128.219 E.16468
G1 X111.835 Y136.014 E1.79694
G3 X111.275 Y135.564 I10.411 J-13.517 E.11714
G1 X119.63 Y127.208 E1.92601
G1 X119.63 Y126.198 E.16468
G1 X110.752 Y135.076 E2.04654
G3 X110.264 Y134.553 I4.132 J-4.342 E.11659
G1 X119.945 Y124.873 E2.23152
; WIPE_START
M204 S6000
G1 X118.531 Y126.287 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.296 Y122.754 Z12.56 F42000
G1 X126.99 Y121.869 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3149.496
M204 S2000
G1 X127.756 Y121.103 E.17655
G2 X127.841 Y120.007 I-2.611 J-.754 E.18034
G1 X126.005 Y121.843 E.42326
G1 X124.543 Y122.295 E.24945
G1 X126.556 Y120.282 E.46404
G1 X125.094 Y120.734 E.24945
G1 X123.081 Y122.747 E.46404
G1 X121.619 Y123.199 E.24945
G1 X124.36 Y120.457 E.63197
G2 X123.8 Y120.007 I-4.366 J4.859 E.1172
G1 X109.812 Y133.995 E3.22442
G3 X109.396 Y133.401 I4.816 J-3.813 E.11832
G1 X123.204 Y119.593 E3.18282
G2 X122.57 Y119.217 I-3.479 J5.127 E.12022
G1 X109.022 Y132.765 E3.12309
G3 X108.689 Y132.087 I5.499 J-3.124 E.1231
G1 X121.894 Y118.882 E3.04398
G2 X121.172 Y118.594 I-2.753 J5.844 E.12679
G1 X108.398 Y131.368 E2.94455
G3 X108.156 Y130.6 I12.736 J-4.446 E.13126
G1 X120.404 Y118.352 E2.82335
G2 X119.579 Y118.167 I-3.118 J11.951 E.13786
G1 X107.973 Y129.772 E2.67529
G3 X107.85 Y128.885 I14.636 J-2.488 E.14599
G1 X118.687 Y118.048 E2.49823
G2 X117.715 Y118.01 I-.894 J10.394 E.15866
G1 X107.815 Y127.91 E2.28219
G3 X107.883 Y126.831 I10.141 J.103 E.1763
G1 X116.639 Y118.076 E2.01829
G2 X115.402 Y118.302 I1.313 J10.665 E.20505
G1 X108.108 Y125.596 E1.68136
G3 X108.615 Y124.079 I7.841 J1.777 E.26124
G1 X113.888 Y118.806 E1.21543
G2 X110.99 Y120.693 I4.011 J9.327 E.56641
G1 X108.943 Y122.741 E.472
; WIPE_START
M204 S6000
G1 X110.357 Y121.326 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X117.585 Y123.779 Z12.56 F42000
G1 X121.662 Y125.163 Z12.56
G1 Z12.16
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X124.337 Y124.337 E.44698
G1 X128.872 Y128.872 E1.02417
G1 X128.872 Y127.128 E.27853
G1 X124.337 Y131.663 E1.02417
G1 X127.011 Y132.49 E.44698
; CHANGE_LAYER
; Z_HEIGHT: 12.72
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
M73 P76 R4
G1 X125.1 Y131.899 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 23/51
; update layer progress
M73 L23
M991 S0 P22 ;notify layer change
M106 S201.45
; OBJECT_ID: 15
M204 S10000
G17
G3 Z12.72 I1.582 J.632 P1  F42000
G1 X129.285 Y121.418 Z12.72
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.285 Y135.186 E2.19844
G1 X119.615 Y132.198 E1.61615
G1 X119.615 Y123.802 E1.34053
M73 P76 R3
G1 X129.285 Y120.814 E1.61615
G1 X129.285 Y121.298 E.07724
; WIPE_START
G1 X129.285 Y123.298 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.713 Y120.93 Z13.12 F42000
G1 Z12.72
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X131.072 Y121.031 E.10372
G2 X129.985 Y121.218 I9.374 J57.859 E.17608
G1 X129.985 Y134.782 E2.16595
G2 X135.798 Y135.538 I10.366 J-56.981 E.93647
G1 X135.781 Y135.94 E.06422
G1 X129.355 Y135.94 E1.026
G1 X118.915 Y132.714 E1.74487
G1 X118.915 Y123.286 E1.50539
G1 X129.355 Y120.06 E1.74486
G1 X135.777 Y120.06 E1.02535
G1 X135.794 Y120.461 E.0642
G2 X132.281 Y120.848 I4.651 J58.429 E.56448
G1 X131.832 Y120.913 E.0724
; WIPE_START
G1 X131.072 Y121.031 E-.29244
G1 X129.985 Y121.218 E-.41904
G1 X129.985 Y121.345 E-.04852
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.595 Y120.766 Z13.12 F42000
G1 X146.875 Y120.06 Z13.12
G1 Z12.72
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y120.06 E.19241
G1 X148.08 Y120.574 E.08205
G2 X146.859 Y120.463 I-3.602 J33.015 E.19574
G1 X146.87 Y120.18 E.04531
; WIPE_START
G1 X148.08 Y120.06 E-.46194
G1 X148.08 Y120.574 E-.19527
G1 X147.811 Y120.549 E-.10279
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.949 Y128.181 Z13.12 F42000
G1 X148.08 Y135.426 Z13.12
G1 Z12.72
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y135.94 E.0821
G1 X146.868 Y135.94 E.19354
G1 X146.852 Y135.537 E.06441
G2 X147.961 Y135.439 I-2.369 J-33.026 E.17777
; WIPE_START
G1 X148.08 Y135.94 E-.19584
G1 X146.868 Y135.94 E-.46058
G1 X146.857 Y135.668 E-.10358
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.156 Y130.593 Z13.12 F42000
G1 X131.184 Y121.718 Z13.12
G1 Z12.72
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.948 Y121.76 E.03831
G1 X130.685 Y121.806 E.04262
G1 X130.685 Y134.194 E1.97819
G1 X130.948 Y134.24 E.04262
G1 X131.185 Y134.282 E.03849
G1 X131.794 Y134.374 E.09835
G1 X132.387 Y134.464 E.0958
G1 X133.472 Y134.605 E.17472
G1 X134.069 Y134.669 E.0958
G1 X134.269 Y134.691 E.03215
G1 X134.866 Y134.755 E.0958
G1 X135.463 Y134.807 E.09581
G1 X135.533 Y134.813 E.01107
G1 X136.13 Y134.865 E.09581
G1 X137.196 Y134.936 E.17051
G2 X148.78 Y134.648 I4.099 J-68.385 E1.85249
G1 X148.78 Y136.64 E.31805
G1 X129.25 Y136.64 E3.11849
G1 X118.215 Y133.23 E1.84416
G1 X118.215 Y122.77 E1.67024
G1 X129.25 Y119.36 E1.84416
G1 X148.78 Y119.36 E3.11849
G1 X148.78 Y121.352 E.31814
G2 X137.179 Y121.065 I-7.491 J68.083 E1.85512
G1 X136.09 Y121.138 E.17432
G1 X135.492 Y121.19 E.09581
G1 X135.433 Y121.195 E.00946
G1 X134.836 Y121.247 E.09581
G1 X134.239 Y121.311 E.0958
G1 X134.193 Y121.316 E.00734
G1 X133.597 Y121.38 E.0958
G1 X133.002 Y121.457 E.0958
G1 X132.972 Y121.461 E.00475
G1 X132.377 Y121.537 E.0958
G1 X131.784 Y121.627 E.09581
G1 X131.303 Y121.7 E.07773
; WIPE_START
M204 S6000
G1 X130.948 Y121.76 E-.13676
M73 P77 R3
G1 X130.685 Y121.806 E-.10144
G1 X130.685 Y123.179 E-.5218
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z13.12 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z13.12
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z13.12 F4000
            G39.3 S1
            G0 Z13.12 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X130.313 Y120.606 F42000
G1 Z12.72
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.5164
G1 F3000
M204 S6000
G1 X129.974 Y120.635 E.03076
; LINE_WIDTH: 0.565131
G1 X129.635 Y120.665 E.03455
M204 S10000
G1 X130.313 Y120.606 F42000
; LINE_WIDTH: 0.467669
G1 F3000
M204 S6000
G1 X130.652 Y120.576 E.02698
; LINE_WIDTH: 0.418937
G1 X130.991 Y120.547 E.0232
; LINE_WIDTH: 0.372351
G1 X131.298 Y120.524 E.01769
; LINE_WIDTH: 0.328253
G1 X131.601 Y120.501 E.01445
; LINE_WIDTH: 0.284384
G1 X131.905 Y120.478 E.0114
; LINE_WIDTH: 0.240515
G1 X132.208 Y120.455 E.00836
; WIPE_START
G1 X131.905 Y120.478 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.135 Y120.247 Z13.12 F42000
G1 Z12.72
G1 E.8 F1800
; LINE_WIDTH: 1.13706
G1 F2212.649
M204 S6000
G1 X137.3 Y120.208 E.27027
; LINE_WIDTH: 1.09972
G1 F2296.988
G1 X137.947 Y120.192 E.14464
; LINE_WIDTH: 1.06876
G1 F2371.949
G1 X138.584 Y120.177 E.13803
; LINE_WIDTH: 1.03432
G1 F2461.316
G1 X139.867 Y120.157 E.26754
; LINE_WIDTH: 1.01212
G1 F2522.589
G1 X143.661 Y120.169 E.7722
; LINE_WIDTH: 1.05226
G1 F2413.946
G1 X144.283 Y120.183 E.13232
; LINE_WIDTH: 1.07835
G1 F2348.231
G1 X144.897 Y120.195 E.13424
; LINE_WIDTH: 1.10802
G1 F2277.701
G1 X145.712 Y120.22 E.1837
; LINE_WIDTH: 1.14111
G1 F2203.872
G1 X146.518 Y120.244 E.18782
; WIPE_START
G1 X145.712 Y120.22 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.104 Y127.842 Z13.12 F42000
G1 X146.51 Y135.755 Z13.12
G1 Z12.72
G1 E.8 F1800
; LINE_WIDTH: 1.14283
G1 F2200.17
M204 S6000
G1 X145.765 Y135.778 E.17399
; LINE_WIDTH: 1.11254
G1 F2267.311
G1 X145.011 Y135.802 E.17085
; LINE_WIDTH: 1.08367
G1 F2335.258
G1 X144.393 Y135.815 E.1359
; LINE_WIDTH: 1.05643
G1 F2403.2
G1 X143.767 Y135.829 E.13383
; LINE_WIDTH: 1.01298
G1 F2520.147
G1 X139.94 Y135.843 E.77946
; LINE_WIDTH: 1.03253
G1 F2466.142
G1 X138.647 Y135.825 E.2693
; LINE_WIDTH: 1.0664
G1 F2377.875
G1 X138.004 Y135.809 E.13882
; LINE_WIDTH: 1.09707
G1 F2303.219
G1 X137.352 Y135.794 E.14543
; LINE_WIDTH: 1.13563
G1 F2215.755
G1 X136.139 Y135.754 E.281
; WIPE_START
G1 X137.352 Y135.794 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.21 Y135.545 Z13.12 F42000
G1 Z12.72
G1 E.8 F1800
; LINE_WIDTH: 0.240492
G1 F3000
M204 S6000
G1 X131.906 Y135.522 E.00836
; LINE_WIDTH: 0.284323
G1 X131.602 Y135.499 E.0114
; LINE_WIDTH: 0.328153
G1 X131.299 Y135.476 E.01445
; LINE_WIDTH: 0.372212
G1 X130.992 Y135.453 E.01769
; LINE_WIDTH: 0.418793
G1 X130.653 Y135.424 E.0232
; LINE_WIDTH: 0.467544
G1 X130.314 Y135.394 E.02699
; LINE_WIDTH: 0.516295
G1 X129.974 Y135.365 E.03078
; LINE_WIDTH: 0.565046
G1 X129.635 Y135.335 E.03457
; WIPE_START
G1 X129.974 Y135.365 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.597 Y133.507 Z13.12 F42000
G1 Z12.72
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.796167
G1 F3328.452
M204 S6000
G1 X128.359 Y133.472 E.03713
G1 X121.332 Y131.301 E1.13446
; LINE_WIDTH: 0.813652
G1 F3244.529
G1 X121.241 Y131.244 E.01688
; LINE_WIDTH: 0.848622
G1 F3088.771
G1 X121.15 Y131.188 E.01773
; LINE_WIDTH: 0.883592
G1 F2947.283
G1 X121.06 Y131.132 E.01858
; LINE_WIDTH: 0.876127
G1 F2976.387
G1 X121.02 Y131.006 E.02266
; LINE_WIDTH: 0.826227
G1 F3186.743
G1 X120.981 Y130.881 E.02116
; LINE_WIDTH: 0.796183
G1 F3328.371
G1 X120.979 Y125.178 E.87968
; LINE_WIDTH: 0.813644
G1 F3244.569
G1 X121.006 Y125.075 E.01688
; LINE_WIDTH: 0.848617
G1 F3088.793
G1 X121.033 Y124.971 E.01773
; LINE_WIDTH: 0.88359
G1 F2947.289
G1 X121.06 Y124.868 E.01858
; LINE_WIDTH: 0.876132
G1 F2976.368
G1 X121.168 Y124.794 E.02266
; LINE_WIDTH: 0.826242
G1 F3186.675
G1 X121.276 Y124.719 E.02116
; LINE_WIDTH: 0.796176
G1 F3328.406
G1 X128.474 Y122.492 E1.16212
G1 X128.597 Y122.493 E.019
G1 X128.597 Y121.747 E.11513
G1 X121.132 Y124.053 E1.20515
; LINE_WIDTH: 0.813652
G1 F3244.529
G1 X120.965 Y124.123 E.02868
; LINE_WIDTH: 0.848622
G1 F3088.771
G1 X120.798 Y124.193 E.03013
; LINE_WIDTH: 0.894323
G1 F2906.43
G3 X120.355 Y124.348 I-1.021 J-2.205 E.08293
; LINE_WIDTH: 0.88359
G1 F2947.289
G1 X120.338 Y124.625 E.04825
; LINE_WIDTH: 0.848617
G1 F3088.793
G1 X120.32 Y124.901 E.04604
; LINE_WIDTH: 0.796975
G1 F3324.478
G1 X120.303 Y125.178 E.04277
G1 X120.303 Y130.822 E.87163
; LINE_WIDTH: 0.813644
G1 F3244.569
G1 X120.32 Y131.003 E.02868
; LINE_WIDTH: 0.848617
G1 F3088.793
G1 X120.338 Y131.183 E.03013
; LINE_WIDTH: 0.894322
G1 F2906.432
G3 X120.355 Y131.652 I-2.409 J.324 E.08293
; LINE_WIDTH: 0.883592
G1 F2947.283
G1 X120.614 Y131.75 E.04825
; LINE_WIDTH: 0.848622
G1 F3088.771
G1 X120.873 Y131.848 E.04604
; LINE_WIDTH: 0.796723
G1 F3325.718
G1 X121.132 Y131.947 E.04276
G1 X128.597 Y134.253 E1.20612
G1 X128.597 Y133.627 E.0967
M204 S10000
G1 X127.129 Y132.372 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X124.454 Y131.546 E.44698
G1 X128.69 Y127.31 E.95653
G1 X128.69 Y128.69 E.22043
G1 X124.454 Y124.454 E.95653
G1 X121.78 Y125.281 E.44698
; CHANGE_LAYER
; Z_HEIGHT: 13.28
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X123.691 Y124.69 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 24/51
; update layer progress
M73 L24
M991 S0 P23 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z13.28 I.798 J1.506 P1  F42000
G1 X129.103 Y121.823 Z13.28
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.103 Y134.597 E2.0397
G1 X119.615 Y131.665 E1.58574
G1 X119.615 Y124.335 E1.17045
G1 X129.103 Y121.403 E1.58574
G1 X129.103 Y121.703 E.04794
; WIPE_START
G1 X129.103 Y123.703 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.249 Y121.309 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X129.803 Y121.6 E.23553
G1 X129.803 Y134.4 E2.04393
G2 X137.504 Y135.539 I12.371 J-57.034 E1.2439
G1 X137.485 Y135.94 E.06406
G1 X131.079 Y135.94 E1.02294
G1 X118.915 Y132.181 E2.03291
G1 X118.915 Y123.819 E1.3353
G1 X131.079 Y120.06 E2.03291
G1 X137.483 Y120.06 E1.0225
G1 X137.5 Y120.461 E.06415
G2 X131.63 Y121.234 I4.665 J58.125 E.94586
G1 X131.367 Y121.286 E.0428
; WIPE_START
G1 X129.803 Y121.6 E-.60613
G1 X129.803 Y122.005 E-.15387
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.766 Y122.12 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.503 Y122.173 E.04283
G1 X130.503 Y133.827 E1.86092
G1 X130.766 Y133.88 E.04283
G1 F2700
G1 X131.765 Y134.081 E.16277
G1 F3000
G1 X132.869 Y134.275 E.17897
G1 F3215.099
G1 X133.998 Y134.448 E.18243
G1 X135.15 Y134.599 E.1854
G1 X136.316 Y134.728 E.18744
G1 X137.494 Y134.836 E.18885
G1 X137.907 Y134.869 E.0662
G1 X138.682 Y134.922 E.12392
G1 X138.898 Y134.935 E.03468
G2 X148.78 Y134.819 I4.131 J-68.819 E1.5793
G1 X148.78 Y136.64 E.29081
G1 X130.973 Y136.64 E2.84329
G1 X118.215 Y132.698 E2.1322
G1 X118.215 Y123.302 E1.50015
G1 X130.973 Y119.36 E2.1322
G1 X148.78 Y119.36 E2.84329
G1 X148.78 Y121.18 E.29068
G2 X138.893 Y121.065 I-5.798 J73.231 E1.57999
G1 X138.624 Y121.082 E.04306
G1 X137.852 Y121.135 E.12361
G1 X137.446 Y121.168 E.06492
G1 X136.604 Y121.243 E.13506
G1 X136.276 Y121.276 E.05259
G1 X135.119 Y121.405 E.18584
G1 X133.977 Y121.555 E.18395
G1 X132.856 Y121.727 E.18119
G1 F3000
G1 X131.76 Y121.92 E.1777
G1 F2700
G1 X130.883 Y122.096 E.14271
; WIPE_START
M204 S6000
G1 X130.503 Y122.173 E-.14752
G1 X130.503 Y123.785 E-.61248
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z13.68 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z13.68
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z13.68 F4000
            G39.3 S1
            G0 Z13.68 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X129.883 Y121.014 F42000
G1 Z13.28
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.572637
G1 F3000
M204 S6000
G1 X130.313 Y120.904 E.04581
; LINE_WIDTH: 0.612416
G1 X130.743 Y120.795 E.04984
; LINE_WIDTH: 0.652196
G1 X131.173 Y120.686 E.05387
; LINE_WIDTH: 0.65498
G1 X131.345 Y120.669 E.02106
; LINE_WIDTH: 0.620787
G1 X131.517 Y120.651 E.01971
; LINE_WIDTH: 0.603139
G1 X131.523 Y120.651 E.00064
; LINE_WIDTH: 0.577717
G1 X131.807 Y120.626 E.02981
; LINE_WIDTH: 0.527958
M73 P78 R3
G1 X132.092 Y120.601 E.02657
; LINE_WIDTH: 0.478199
G1 X132.376 Y120.576 E.02333
; LINE_WIDTH: 0.42844
G1 X132.661 Y120.551 E.02008
; LINE_WIDTH: 0.380313
G1 X132.981 Y120.527 E.01908
; LINE_WIDTH: 0.334198
G1 X133.298 Y120.503 E.01553
; LINE_WIDTH: 0.288332
G1 X133.615 Y120.48 E.0122
; LINE_WIDTH: 0.242467
G1 X133.933 Y120.456 E.00887
; WIPE_START
G1 X133.615 Y120.48 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.841 Y120.247 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 1.13673
G1 F2213.37
M204 S6000
G1 X139.054 Y120.207 E.28157
; LINE_WIDTH: 1.09816
G1 F2300.662
G1 X139.698 Y120.191 E.14369
; LINE_WIDTH: 1.06761
G1 F2374.85
G1 X140.333 Y120.176 E.13718
; LINE_WIDTH: 1.03367
G1 F2463.084
G1 X141.607 Y120.157 E.26556
; LINE_WIDTH: 1.01202
G1 F2522.875
G1 X145.378 Y120.169 E.76745
; LINE_WIDTH: 1.05192
G1 F2414.84
G1 X145.996 Y120.182 E.13146
; LINE_WIDTH: 1.07775
G1 F2349.701
G1 X146.606 Y120.195 E.13333
; LINE_WIDTH: 1.10873
G1 F2276.053
G1 X147.215 Y120.213 E.1373
; LINE_WIDTH: 1.14493
G1 F2195.641
G1 X147.815 Y120.231 E.14031
; LINE_WIDTH: 1.16666
G1 F2150.068
G1 X148.43 Y120.255 E.14704
; WIPE_START
G1 X147.815 Y120.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.128 Y127.857 Z13.68 F42000
G1 X148.43 Y135.202 Z13.68
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 1.06895
G1 F2371.477
M204 S6000
G1 X147.952 Y135.716 E.15202
; LINE_WIDTH: 1.10015
G1 F2295.991
G1 X147.929 Y135.741 E.00756
; LINE_WIDTH: 1.13403
G1 F2219.248
G1 X147.905 Y135.765 E.00782
G1 X146.745 Y135.801 E.26858
; LINE_WIDTH: 1.09753
G1 F2302.144
G1 X146.736 Y135.802 E.00197
; LINE_WIDTH: 1.08381
G1 F2334.916
G1 X146.122 Y135.815 E.13507
; LINE_WIDTH: 1.05669
G1 F2402.525
G1 X145.499 Y135.829 E.13304
; LINE_WIDTH: 1.01767
G1 F2506.98
G1 X142.984 Y135.85 E.51514
G1 X140.411 Y135.825 E.52682
; LINE_WIDTH: 1.06459
G1 F2382.427
G1 X139.772 Y135.81 E.13787
; LINE_WIDTH: 1.09472
G1 F2308.769
G1 X139.123 Y135.795 E.14436
; LINE_WIDTH: 1.13493
G1 F2217.292
G1 X137.844 Y135.753 E.29616
; WIPE_START
G1 X139.123 Y135.795 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.93 Y135.544 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 0.2422
G1 F3000
M204 S6000
G1 X133.617 Y135.521 E.00874
; LINE_WIDTH: 0.287486
G1 X133.304 Y135.497 E.01198
; LINE_WIDTH: 0.332773
G1 X132.99 Y135.474 E.01523
; LINE_WIDTH: 0.378303
G1 X132.674 Y135.45 E.01869
; LINE_WIDTH: 0.421275
G1 X132.445 Y135.43 E.0158
; LINE_WIDTH: 0.46131
G1 X132.216 Y135.41 E.0179
; LINE_WIDTH: 0.501345
G1 X131.987 Y135.39 E.02
; LINE_WIDTH: 0.54138
G1 X131.758 Y135.37 E.0221
; LINE_WIDTH: 0.581924
G1 X131.523 Y135.349 E.02484
; LINE_WIDTH: 0.619916
G1 X131.348 Y135.332 E.02003
; LINE_WIDTH: 0.654714
G1 X131.173 Y135.314 E.02142
; LINE_WIDTH: 0.652207
G1 X130.743 Y135.205 E.05387
; LINE_WIDTH: 0.612423
G1 X130.313 Y135.096 E.04984
; LINE_WIDTH: 0.572639
G1 X129.883 Y134.986 E.04581
; LINE_WIDTH: 0.532854
G1 X129.453 Y134.877 E.04179
; WIPE_START
G1 X129.883 Y134.986 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X122.88 Y131.952 Z13.68 F42000
G1 X121.275 Y131.257 Z13.68
G1 Z13.28
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.17996
G1 F2123.082
M204 S6000
G1 X128.109 Y133.369 E1.72953
M204 S10000
G1 X121.275 Y131.257 F42000
; LINE_WIDTH: 1.15791
G1 F2168.182
M204 S6000
G1 X121.245 Y131.201 E.01518
; LINE_WIDTH: 1.11382
G1 F2264.386
G1 X121.214 Y131.144 E.01454
; LINE_WIDTH: 1.06974
G1 F2369.524
G1 X121.184 Y131.088 E.01389
; LINE_WIDTH: 1.02565
G1 F2484.899
G1 X121.154 Y131.031 E.01325
; LINE_WIDTH: 0.981558
G1 F2612.086
G1 X121.123 Y130.975 E.0126
; LINE_WIDTH: 0.937469
G1 F2752.994
G1 X121.093 Y130.918 E.01196
; LINE_WIDTH: 0.89338
G1 F2909.973
G1 X121.062 Y130.862 E.01131
; LINE_WIDTH: 0.849291
G1 F3085.936
G1 X121.032 Y130.805 E.01067
; LINE_WIDTH: 0.79678
G1 F3325.438
G1 X120.979 Y130.595 E.03344
G1 X120.979 Y125.405 E.80136
; LINE_WIDTH: 0.815623
G1 F3235.333
G1 X121.008 Y125.304 E.01664
; LINE_WIDTH: 0.854556
G1 F3063.814
G1 X121.038 Y125.203 E.01757
; LINE_WIDTH: 0.893488
G1 F2909.566
G1 X121.067 Y125.103 E.0185
; LINE_WIDTH: 0.932421
G1 F2770.105
G1 X121.097 Y125.002 E.01943
; LINE_WIDTH: 0.975498
G1 F2630.591
G1 X121.115 Y124.956 E.0096
; LINE_WIDTH: 1.02272
G1 F2492.956
G1 X121.133 Y124.911 E.01013
; LINE_WIDTH: 1.06994
G1 F2369.007
G1 X121.151 Y124.865 E.01066
; LINE_WIDTH: 1.11716
G1 F2256.8
G1 X121.17 Y124.819 E.01119
; LINE_WIDTH: 1.16439
G1 F2154.741
G1 X121.188 Y124.774 E.01172
; LINE_WIDTH: 1.16545
G1 F2152.548
G1 X121.128 Y124.769 E.01444
; LINE_WIDTH: 1.12036
G1 F2249.597
G1 X121.067 Y124.764 E.01382
; LINE_WIDTH: 1.07526
G1 F2355.81
G1 X121.007 Y124.759 E.0132
; LINE_WIDTH: 1.03017
G1 F2472.55
G1 X120.947 Y124.754 E.01257
; LINE_WIDTH: 0.985075
G1 F2601.463
G1 X120.886 Y124.749 E.01195
; LINE_WIDTH: 0.939981
G1 F2744.557
G1 X120.826 Y124.744 E.01133
; LINE_WIDTH: 0.894888
G1 F2904.31
G1 X120.766 Y124.739 E.0107
; LINE_WIDTH: 0.830179
G1 F3169.003
G1 X120.705 Y124.734 E.00981
G1 X120.318 Y124.854 E.06561
; LINE_WIDTH: 0.798879
G1 F3315.151
G1 X120.303 Y125.405 E.08532
G1 X120.303 Y130.595 E.80385
G1 X120.318 Y131.146 E.08532
; LINE_WIDTH: 0.847862
G1 F3091.997
G1 X120.896 Y131.303 E.0994
; LINE_WIDTH: 0.890726
G1 F2919.998
G1 X120.933 Y131.299 E.00658
; LINE_WIDTH: 0.935223
G1 F2760.581
G1 X120.97 Y131.294 E.00696
; LINE_WIDTH: 0.97972
G1 F2617.671
G1 X121.007 Y131.29 E.00733
; LINE_WIDTH: 1.02422
G1 F2488.828
G1 X121.044 Y131.285 E.00771
; LINE_WIDTH: 1.06871
G1 F2372.074
G1 X121.082 Y131.281 E.00809
; LINE_WIDTH: 1.11321
G1 F2265.783
G1 X121.119 Y131.276 E.00847
; LINE_WIDTH: 1.15771
G1 F2168.609
G1 X121.156 Y131.272 E.00885
M204 S10000
G1 X128.223 Y122.596 F42000
; LINE_WIDTH: 1.17998
G1 F2123.042
M204 S6000
G1 X121.301 Y124.735 E1.75189
M204 S10000
G1 X121.953 Y125.454 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X124.628 Y124.628 E.44698
G1 X128.508 Y128.508 E.87632
G1 X128.508 Y127.492 E.16232
G1 X124.628 Y131.372 E.87632
G1 X121.953 Y130.546 E.44698
; WIPE_START
G1 X123.864 Y131.136 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.584 Y124.472 Z13.68 F42000
G1 X129.453 Y121.123 Z13.68
G1 Z13.28
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.532857
G1 F3000
M204 S6000
G1 X129.883 Y121.014 E.04179
; CHANGE_LAYER
; Z_HEIGHT: 13.84
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3000
G1 X129.453 Y121.123 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 25/51
; update layer progress
M73 L25
M991 S0 P24 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z13.84 I-1.53 J-.75 P1  F42000
G1 X128.921 Y122.208 Z13.84
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.921 Y134.008 E1.88422
G1 X119.615 Y131.133 E1.55533
G1 X119.615 Y124.867 E1.00037
G1 X128.921 Y121.992 E1.55533
G1 X128.921 Y122.088 E.01538
; WIPE_START
G1 X128.921 Y124.088 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.009 Y121.744 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X129.621 Y122.102 E.22892
G1 X129.621 Y133.898 E1.88346
G2 X139.219 Y135.539 I13.298 J-48.889 E1.55728
G1 X139.202 Y135.94 E.06415
G1 X132.802 Y135.94 E1.02181
G1 X118.915 Y131.649 E2.32095
G1 X118.915 Y124.351 E1.16522
G1 X132.802 Y120.06 E2.32095
G1 X139.227 Y120.06 E1.02576
G1 X139.244 Y120.462 E.06424
G2 X131.198 Y121.701 I3.651 J50.458 E1.30121
G1 X131.126 Y121.717 E.01181
; WIPE_START
G1 X129.621 Y122.102 E-.59038
G1 X129.621 Y122.549 E-.16962
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.584 Y122.576 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.321 Y122.644 E.04336
G1 X130.321 Y133.356 E1.71035
G1 X130.584 Y133.424 E.04336
G1 F2100
G1 X131.367 Y133.626 E.12912
G1 F2400
G1 X132.398 Y133.862 E.16897
G1 F2700
G1 X133.465 Y134.077 E.17371
G1 F3000
G1 X134.561 Y134.27 E.17783
G1 F3215.099
G1 X135.684 Y134.443 E.18128
G1 X136.827 Y134.594 E.18419
G1 X137.985 Y134.723 E.18601
G1 X138.432 Y134.767 E.07172
G1 X139.157 Y134.831 E.11623
G1 X139.684 Y134.873 E.08435
G1 X140.336 Y134.917 E.10444
G1 X140.637 Y134.936 E.04812
G2 X148.78 Y134.942 I4.122 J-70.059 E1.30096
G1 X148.78 Y136.64 E.27117
G1 X132.697 Y136.64 E2.56809
G1 X118.215 Y132.165 E2.42024
G1 X118.215 Y123.835 E1.33007
G1 X132.697 Y119.36 E2.42024
G1 X148.78 Y119.36 E2.56809
G1 X148.78 Y121.059 E.27123
G2 X140.644 Y121.064 I-4.016 J74.917 E1.29969
G1 X139.612 Y121.133 E.16519
G1 X139.014 Y121.184 E.0958
G1 X138.968 Y121.188 E.00737
G1 X138.37 Y121.239 E.0958
G1 X137.774 Y121.302 E.09581
G1 X137.74 Y121.306 E.00537
G1 X137.144 Y121.369 E.09581
G1 X136.548 Y121.444 E.09581
G1 X136.53 Y121.447 E.0029
G1 X135.935 Y121.522 E.09581
G1 X134.754 Y121.699 E.19073
G1 X134.534 Y121.734 E.03554
G1 F3000
G1 X133.447 Y121.927 E.17628
G1 F2700
G1 X132.388 Y122.141 E.17259
G1 F2400
G1 X131.363 Y122.375 E.1679
G1 F2100
G1 X130.7 Y122.546 E.10928
; WIPE_START
M204 S6000
G1 X130.321 Y122.644 E-.14879
G1 X130.321 Y124.253 E-.61121
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z14.24 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z14.24
M73 P79 R3
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z14.24 F4000
            G39.3 S1
            G0 Z14.24 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X129.271 Y121.675 F42000
G1 Z13.84
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.449648
G1 F3000
M204 S6000
G1 X130.168 Y121.421 E.0701
; LINE_WIDTH: 0.489651
G1 X131.066 Y121.167 E.07862
; LINE_WIDTH: 0.530005
G1 X131.592 Y121.025 E.051
; LINE_WIDTH: 0.570633
G1 X132.114 Y120.885 E.0555
; LINE_WIDTH: 0.611226
G1 X132.508 Y120.785 E.04561
; LINE_WIDTH: 0.651832
G1 X132.897 Y120.686 E.04864
; LINE_WIDTH: 0.656701
G1 X133.05 Y120.67 E.01884
; LINE_WIDTH: 0.626109
G1 X133.203 Y120.655 E.01776
; LINE_WIDTH: 0.610249
G1 X133.209 Y120.654 E.00066
; LINE_WIDTH: 0.585016
G1 X133.49 Y120.63 E.02993
; LINE_WIDTH: 0.535615
G1 X133.771 Y120.605 E.02675
; LINE_WIDTH: 0.486214
G1 X134.052 Y120.58 E.02357
; LINE_WIDTH: 0.436813
G1 X134.333 Y120.556 E.02038
; LINE_WIDTH: 0.392852
G1 X134.572 Y120.536 E.01492
; LINE_WIDTH: 0.354121
G1 X134.847 Y120.516 E.01468
; LINE_WIDTH: 0.315315
G1 X135.119 Y120.496 E.01217
; LINE_WIDTH: 0.276621
G1 X135.392 Y120.476 E.00976
; LINE_WIDTH: 0.237926
G1 X135.665 Y120.455 E.00735
; WIPE_START
G1 X135.392 Y120.476 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.585 Y120.246 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 1.13518
G1 F2216.741
M204 S6000
G1 X140.809 Y120.206 E.28362
; LINE_WIDTH: 1.09661
G1 F2304.296
G1 X141.448 Y120.191 E.14255
; LINE_WIDTH: 1.06651
G1 F2377.608
G1 X142.079 Y120.176 E.13615
; LINE_WIDTH: 1.03307
G1 F2464.692
G1 X143.347 Y120.157 E.26407
; LINE_WIDTH: 1.01192
G1 F2523.142
G1 X147.095 Y120.169 E.76271
; LINE_WIDTH: 1.05747
G1 F2400.522
G1 X148.43 Y120.198 E.28556
; WIPE_START
G1 X147.095 Y120.169 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.745 Y127.774 Z14.24 F42000
G1 X148.43 Y135.802 Z14.24
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 1.05927
G1 F2395.918
M204 S6000
G1 X147.232 Y135.828 E.25667
; LINE_WIDTH: 1.0173
G1 F2508.019
G1 X144.725 Y135.85 E.5132
G1 X142.173 Y135.826 E.52243
; LINE_WIDTH: 1.06288
G1 F2386.755
G1 X141.538 Y135.811 E.13675
; LINE_WIDTH: 1.09237
G1 F2314.348
G1 X140.895 Y135.797 E.14265
; LINE_WIDTH: 1.12605
G1 F2236.863
G1 X140.278 Y135.778 E.14156
; LINE_WIDTH: 1.1517
G1 F2181.235
G1 X139.56 Y135.753 E.16904
; WIPE_START
G1 X140.278 Y135.778 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.657 Y135.544 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 0.242827
G1 F3000
M204 S6000
G1 X135.335 Y135.52 E.00903
; LINE_WIDTH: 0.289448
G1 X135.013 Y135.496 E.01247
; LINE_WIDTH: 0.336069
G1 X134.691 Y135.472 E.0159
; LINE_WIDTH: 0.382945
G1 X134.366 Y135.447 E.01957
; LINE_WIDTH: 0.431513
G1 X134.081 Y135.422 E.02029
; LINE_WIDTH: 0.481386
G1 X133.797 Y135.397 E.02353
; LINE_WIDTH: 0.531259
G1 X133.512 Y135.372 E.02678
; LINE_WIDTH: 0.581132
G1 X133.228 Y135.347 E.03003
; LINE_WIDTH: 0.606617
G1 X133.222 Y135.347 E.00065
; LINE_WIDTH: 0.62338
G1 X133.059 Y135.331 E.01874
; LINE_WIDTH: 0.636204
G1 X132.897 Y135.314 E.01922
G1 X132.131 Y135.119 E.09309
; LINE_WIDTH: 0.59204
G1 X132.125 Y135.118 E.00066
; LINE_WIDTH: 0.571403
G1 X131.6 Y134.977 E.05594
; LINE_WIDTH: 0.530436
G1 X131.07 Y134.835 E.05137
; LINE_WIDTH: 0.48984
G1 X130.171 Y134.58 E.07885
; LINE_WIDTH: 0.449681
G1 X129.271 Y134.325 E.07028
; WIPE_START
G1 X130.171 Y134.58 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X123.535 Y130.807 Z14.24 F42000
G1 X122.36 Y130.139 Z14.24
G1 Z13.84
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X125.034 Y130.966 E.44698
G1 X128.326 Y127.674 E.74336
G1 X128.326 Y128.326 E.10421
G1 X125.034 Y125.034 E.74335
G1 X122.36 Y125.861 E.44698
M204 S10000
G1 X120.495 Y125.517 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.18009
G1 F2122.822
M204 S6000
G1 X127.927 Y123.22 E1.88117
M204 S10000
G1 X120.495 Y130.483 F42000
; LINE_WIDTH: 1.18007
G1 F2122.862
M204 S6000
G1 X127.927 Y132.78 E1.88114
; CHANGE_LAYER
; Z_HEIGHT: 14.4
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2122.862
G1 X126.016 Y132.19 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 26/51
; update layer progress
M73 L26
M991 S0 P25 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z14.4 I1.625 J.513 P1  F42000
G1 X128.739 Y123.566 Z14.4
G1 E.8 F1800
M106 S255
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.739 Y133.42 E1.57335
G1 X119.615 Y130.6 E1.52492
G1 X119.615 Y125.4 E.83029
G1 X128.739 Y122.58 E1.52492
G1 X128.739 Y123.446 E.13822
M204 S10000
G1 X129.439 Y123.317 F42000
G1 F3215.099
M204 S6000
G1 X129.439 Y133.297 E1.59365
G2 X139.584 Y135.413 I14.416 J-43.736 E1.65821
G2 X140.94 Y135.539 I7.267 J-71.193 E.21745
G1 X140.922 Y135.94 E.06415
G1 X134.526 Y135.94 E1.02128
G1 X118.915 Y131.116 E2.60899
G1 X118.915 Y124.884 E.99514
G1 X134.526 Y120.06 E2.60898
G1 X140.95 Y120.06 E1.02584
G1 X140.968 Y120.462 E.06426
G2 X131.903 Y121.958 I3.598 J50.001 E1.46894
G2 X129.439 Y122.703 I21.601 J75.936 E.4111
G1 X129.439 Y123.197 E.07888
M204 S250
G1 X130.402 Y123.138 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.139 Y123.219 E.04395
G1 X130.139 Y132.781 E1.52685
G1 X130.402 Y132.862 E.04395
G1 F1500
G1 X131.155 Y133.095 E.12586
M106 S201.45
G1 F1650
G1 X132.094 Y133.368 E.15613
G1 F1950
G1 X133.079 Y133.623 E.16254
G1 F2400
G1 X134.105 Y133.858 E.16796
G1 F2700
G1 X135.164 Y134.072 E.17264
G1 F3000
G1 X136.254 Y134.265 E.17671
G1 F3215.099
G1 X137.369 Y134.437 E.1801
G1 X138.504 Y134.588 E.18282
G1 X138.982 Y134.644 E.07691
G1 X139.656 Y134.717 E.10819
G1 X140.214 Y134.772 E.08963
M106 S255
G1 X140.819 Y134.826 E.09699
G1 X141.461 Y134.877 E.10272
G1 X142.425 Y134.939 E.15432
G2 X148.78 Y135.021 I4.218 J-79.96 E1.01505
G1 X148.78 Y136.64 E.25848
G1 X134.42 Y136.64 E2.29289
G1 X118.215 Y131.632 E2.70828
G1 X118.215 Y124.368 E1.15999
G1 X134.42 Y119.36 E2.70828
G1 X148.78 Y119.36 E2.29289
G1 X148.78 Y120.978 E.2583
G2 X142.376 Y121.064 I-2.119 J80.504 E1.02291
G1 X141.373 Y121.13 E.1605
G1 X140.775 Y121.181 E.0958
G1 X140.736 Y121.184 E.00633
G1 X140.138 Y121.235 E.0958
G1 X139.541 Y121.297 E.0958
G1 X138.918 Y121.363 E.1
G1 X138.448 Y121.419 E.07564
G1 X137.715 Y121.515 E.11806
G1 X137.321 Y121.57 E.06344
G1 X136.537 Y121.689 E.12673
G1 X136.215 Y121.742 E.05206
G1 F3000
G1 X135.387 Y121.887 E.13424
G1 F2850
G1 X135.134 Y121.934 E.04114
G1 F2700
G1 X134.272 Y122.107 E.14033
G1 F2550
G1 X134.081 Y122.147 E.03117
G1 F2400
G1 X133.064 Y122.381 E.16662
G1 F1950
G1 X132.089 Y122.633 E.16079
G1 F1650
G1 X131.155 Y122.905 E.15535
G1 F1500
G1 X130.516 Y123.102 E.10669
M106 S201.45
; WIPE_START
M204 S6000
G1 X130.139 Y123.219 E-.15018
G1 X130.139 Y124.824 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
M73 P80 R3
G3 Z14.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z14.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z14.8 F4000
            G39.3 S1
            G0 Z14.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X129.089 Y122.275 F42000
G1 Z14.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.446466
G1 F3000
M204 S6000
G1 X131.763 Y121.457 E.20819
; LINE_WIDTH: 0.484032
G1 X132.766 Y121.173 E.08655
; LINE_WIDTH: 0.528246
G1 X133.288 Y121.033 E.05026
; LINE_WIDTH: 0.568107
G1 X133.804 Y120.894 E.05462
; LINE_WIDTH: 0.609015
G1 X134.215 Y120.789 E.04733
; LINE_WIDTH: 0.651029
G1 X134.62 Y120.686 E.05068
; LINE_WIDTH: 0.658621
G1 X134.753 Y120.672 E.01631
; LINE_WIDTH: 0.63211
G1 X134.885 Y120.659 E.01551
; LINE_WIDTH: 0.618299
G1 X134.891 Y120.658 E.00068
; LINE_WIDTH: 0.592941
G1 X135.171 Y120.634 E.0304
; LINE_WIDTH: 0.543349
G1 X135.452 Y120.609 E.02721
; LINE_WIDTH: 0.493757
G1 X135.733 Y120.584 E.02402
; LINE_WIDTH: 0.444165
G1 X136.013 Y120.559 E.02083
; LINE_WIDTH: 0.405505
G1 X136.185 Y120.545 E.01123
; LINE_WIDTH: 0.378
G1 X136.355 Y120.532 E.01001
; LINE_WIDTH: 0.340037
G1 X136.698 Y120.506 E.01724
; LINE_WIDTH: 0.291565
G1 X137.039 Y120.481 E.01338
; LINE_WIDTH: 0.243198
G1 X137.38 Y120.455 E.0096
; WIPE_START
G1 X137.039 Y120.481 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.309 Y120.246 Z14.8 F42000
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 1.13425
G1 F2218.771
M204 S6000
G1 X142.563 Y120.205 E.29035
; LINE_WIDTH: 1.09509
G1 F2307.907
G1 X143.199 Y120.19 E.14163
; LINE_WIDTH: 1.06537
G1 F2380.46
G1 X143.827 Y120.175 E.13533
; LINE_WIDTH: 1.05047
G1 F2418.594
G1 X143.835 Y120.175 E.0018
; LINE_WIDTH: 1.01458
G1 F2515.649
G1 X146.34 Y120.15 E.51125
G1 X148.43 Y120.164 E.42646
; WIPE_START
G1 X146.43 Y120.151 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.396 Y127.722 Z14.8 F42000
G1 X148.43 Y135.835 Z14.8
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 1.01395
G1 F2517.421
M204 S6000
G1 X146.473 Y135.85 E.39917
G1 X143.937 Y135.827 E.51708
; LINE_WIDTH: 1.06109
G1 F2391.304
G1 X143.305 Y135.812 E.13582
; LINE_WIDTH: 1.09008
G1 F2319.83
G1 X142.663 Y135.798 E.14204
; LINE_WIDTH: 1.11862
G1 F2253.51
G1 X141.972 Y135.776 E.15756
; LINE_WIDTH: 1.14634
G1 F2192.626
G1 X141.281 Y135.753 E.16193
; WIPE_START
G1 X141.972 Y135.776 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.383 Y135.544 Z14.8 F42000
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 0.226713
G1 F3000
M204 S6000
G1 X137.211 Y135.533 E.0042
; LINE_WIDTH: 0.256975
G1 X136.923 Y135.511 E.009
; LINE_WIDTH: 0.301091
G1 X136.635 Y135.489 E.01191
; LINE_WIDTH: 0.345207
G1 X136.348 Y135.467 E.01481
; LINE_WIDTH: 0.389574
G1 X136.057 Y135.444 E.01793
; LINE_WIDTH: 0.436771
G1 X135.774 Y135.42 E.02049
; LINE_WIDTH: 0.486478
G1 X135.492 Y135.395 E.02371
; LINE_WIDTH: 0.536185
G1 X135.209 Y135.37 E.02693
; LINE_WIDTH: 0.585893
G1 X134.926 Y135.345 E.03014
; LINE_WIDTH: 0.611305
G1 X134.921 Y135.344 E.00066
; LINE_WIDTH: 0.626863
G1 X134.771 Y135.329 E.01744
; LINE_WIDTH: 0.656875
G1 X134.62 Y135.314 E.01847
; LINE_WIDTH: 0.651606
G1 X134.229 Y135.215 E.04904
; LINE_WIDTH: 0.610723
G1 X133.831 Y135.113 E.04594
; LINE_WIDTH: 0.570051
G1 X133.309 Y134.973 E.05546
; LINE_WIDTH: 0.529504
G1 X132.782 Y134.831 E.05097
; LINE_WIDTH: 0.484535
G1 X131.768 Y134.544 E.08762
; LINE_WIDTH: 0.446477
G1 X129.089 Y133.725 E.20855
; WIPE_START
G1 X131.002 Y134.31 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X123.952 Y131.385 Z14.8 F42000
G1 X120.495 Y129.951 Z14.8
G1 Z14.4
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.18011
G1 F2122.782
M204 S6000
G1 X127.745 Y132.191 E1.83515
M204 S10000
G1 X122.767 Y126.268 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X125.441 Y125.441 E.44698
G1 X128.144 Y128.144 E.61039
G1 X128.144 Y127.856 E.0461
G1 X125.441 Y130.559 E.61039
G1 X122.767 Y129.732 E.44698
M204 S10000
G1 X120.495 Y126.049 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.18009
G1 F2122.822
M204 S6000
G1 X127.745 Y123.809 E1.83512
; CHANGE_LAYER
; Z_HEIGHT: 14.96
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F2122.822
G1 X125.834 Y124.399 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 27/51
; update layer progress
M73 L27
M991 S0 P26 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z14.96 I.638 J1.58 P1  F42000
G1 X128.557 Y123.3 Z14.96
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.557 Y132.831 E1.52181
G1 X119.615 Y130.067 E1.49451
G1 X119.615 Y125.933 E.6602
G1 X128.557 Y123.169 E1.49451
G1 X128.557 Y123.18 E.00171
; WIPE_START
G1 X128.557 Y125.18 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.594 Y122.878 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X129.257 Y123.291 E.22345
G1 X129.257 Y132.708 E1.50366
G2 X133.626 Y134.042 I43.111 J-133.446 E.72945
G2 X141.931 Y135.474 I12.532 J-47.861 E1.34732
G2 X142.663 Y135.537 I3.801 J-40.161 E.11726
G1 X142.647 Y135.94 E.06444
G1 X136.249 Y135.94 E1.02154
G1 X118.915 Y130.584 E2.89703
G1 X118.915 Y125.416 E.82505
G1 X136.249 Y120.06 E2.89703
G1 X142.674 Y120.06 E1.02583
G1 X142.691 Y120.462 E.06428
G2 X133.616 Y121.961 I3.539 J49.645 E1.47076
G2 X132.677 Y122.235 I38.991 J135.549 E.15612
G1 X130.709 Y122.843 E.32901
; WIPE_START
G1 X129.257 Y123.291 E-.57737
G1 X129.257 Y123.772 E-.18263
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.22 Y123.726 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.957 Y123.808 E.04394
G1 X129.957 Y132.192 E1.33881
G1 X130.22 Y132.274 E.04394
G1 F2250
G1 X130.793 Y132.451 E.0958
G1 F1800
G1 X131.549 Y132.684 E.12635
G1 F1380
G1 X132.878 Y133.095 E.22215
M106 S201.45
G1 F1650
G1 X133.812 Y133.367 E.15526
G1 F1950
G1 X134.792 Y133.62 E.1616
G1 F2400
G1 X135.811 Y133.854 E.16695
G1 F2700
G1 X136.864 Y134.067 E.17157
G1 F3000
G1 X137.947 Y134.26 E.17559
M106 S255
G1 F3215.099
G1 X139.054 Y134.432 E.17893
G1 X140.182 Y134.582 E.18178
G1 X141.325 Y134.712 E.18362
G1 X141.997 Y134.778 E.10777
G1 X142.482 Y134.821 E.07776
G1 X143.236 Y134.88 E.12081
G1 X143.645 Y134.909 E.06548
G1 X144.117 Y134.937 E.07543
G2 X148.78 Y135.055 I4.578 J-88.913 E.74493
G1 X148.78 Y136.64 E.25308
G1 X136.144 Y136.64 E2.01769
G1 X118.215 Y131.1 E2.99632
G1 X118.215 Y124.9 E.98991
G1 X136.144 Y119.36 E2.99632
G1 X148.78 Y119.36 E2.01769
G1 X148.78 Y120.945 E.25307
G2 X144.108 Y121.063 I-.56 J70.033 E.74644
G1 X143.134 Y121.127 E.15578
G1 X142.536 Y121.177 E.09581
G1 X142.503 Y121.18 E.00528
G1 X141.905 Y121.231 E.09581
G1 X141.288 Y121.295 E.09905
G1 X140.692 Y121.357 E.0958
G1 X140.113 Y121.427 E.09306
G1 X139.494 Y121.507 E.09974
G1 X138.994 Y121.577 E.0805
G1 X138.32 Y121.68 E.10887
G1 X137.895 Y121.749 E.06881
G1 F3000
G1 X136.822 Y121.941 E.17398
G1 F2700
G1 X135.777 Y122.153 E.17034
G1 F2250
G1 X134.765 Y122.386 E.16576
G1 F1950
G1 X133.802 Y122.636 E.1589
G1 F1650
G1 X132.878 Y122.905 E.1536
G1 F1380
G1 X132.305 Y123.082 E.0958
M106 S201.45
M73 P81 R3
G1 F1800
G1 X131.549 Y123.316 E.12634
G1 F2250
G1 X130.334 Y123.691 E.20299
; WIPE_START
M204 S6000
G1 X129.957 Y123.808 E-.15018
G1 X129.957 Y125.413 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z15.36 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z15.36
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z15.36 F4000
            G39.3 S1
            G0 Z15.36 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X128.907 Y122.864 F42000
G1 Z14.96
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.445176
G1 F3000
M204 S6000
G1 X133.475 Y121.461 E.35437
; LINE_WIDTH: 0.483174
G1 X134.467 Y121.179 E.08539
; LINE_WIDTH: 0.526697
G1 X134.987 Y121.039 E.04997
; LINE_WIDTH: 0.56612
G1 X135.503 Y120.9 E.05428
; LINE_WIDTH: 0.607298
G1 X135.926 Y120.792 E.04859
; LINE_WIDTH: 0.650297
G1 X136.344 Y120.685 E.05216
; LINE_WIDTH: 0.647843
G1 X136.581 Y120.662 E.02863
; LINE_WIDTH: 0.599459
G1 X136.858 Y120.637 E.03049
; LINE_WIDTH: 0.550182
G1 X137.136 Y120.612 E.02735
; LINE_WIDTH: 0.500905
G1 X137.414 Y120.588 E.02422
; LINE_WIDTH: 0.451628
G1 X137.691 Y120.563 E.02108
; LINE_WIDTH: 0.408849
G1 X137.916 Y120.545 E.01488
; LINE_WIDTH: 0.372788
G1 X138.139 Y120.527 E.01287
; LINE_WIDTH: 0.332133
G1 X138.462 Y120.503 E.01567
; LINE_WIDTH: 0.286808
G1 X138.784 Y120.479 E.01226
; LINE_WIDTH: 0.241589
G1 X139.106 Y120.455 E.00893
; WIPE_START
G1 X138.784 Y120.479 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.032 Y120.246 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 1.14623
G1 F2192.864
M204 S6000
G1 X143.675 Y120.225 E.15056
; LINE_WIDTH: 1.12098
G1 F2248.188
G1 X144.318 Y120.204 E.14685
; LINE_WIDTH: 1.09353
G1 F2311.606
G1 X144.951 Y120.189 E.14061
; LINE_WIDTH: 1.06424
G1 F2383.319
G1 X145.574 Y120.175 E.13434
; LINE_WIDTH: 1.01823
G1 F2505.414
G1 X148.43 Y120.148 E.58523
; WIPE_START
G1 X146.43 Y120.167 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.396 Y127.738 Z15.36 F42000
G1 X148.43 Y135.851 Z15.36
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 1.01421
G1 F2516.693
M204 S6000
G1 X145.946 Y135.831 E.50671
; LINE_WIDTH: 1.0536
G1 F2410.483
G1 X145.195 Y135.815 E.1601
; LINE_WIDTH: 1.08586
G1 F2329.945
G1 X144.433 Y135.799 E.16789
; LINE_WIDTH: 1.11664
G1 F2257.982
G1 X143.719 Y135.776 E.16242
; LINE_WIDTH: 1.14549
G1 F2194.447
G1 X143.005 Y135.754 E.16712
; WIPE_START
G1 X143.719 Y135.776 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.109 Y135.544 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 0.229571
G1 F3000
M204 S6000
G1 X138.895 Y135.53 E.00537
; LINE_WIDTH: 0.262629
G1 X138.609 Y135.508 E.00932
; LINE_WIDTH: 0.306653
G1 X138.323 Y135.486 E.0122
; LINE_WIDTH: 0.350677
G1 X138.037 Y135.464 E.01507
; LINE_WIDTH: 0.394956
G1 X137.748 Y135.442 E.01818
; LINE_WIDTH: 0.442047
G1 X137.467 Y135.417 E.02071
; LINE_WIDTH: 0.491626
G1 X137.186 Y135.392 E.0239
; LINE_WIDTH: 0.541205
G1 X136.905 Y135.367 E.02709
; LINE_WIDTH: 0.590784
G1 X136.625 Y135.343 E.03028
; LINE_WIDTH: 0.616135
G1 X136.619 Y135.342 E.00067
; LINE_WIDTH: 0.630447
G1 X136.481 Y135.328 E.01607
; LINE_WIDTH: 0.657987
G1 X136.344 Y135.314 E.01694
; LINE_WIDTH: 0.651104
G1 X135.943 Y135.212 E.05011
; LINE_WIDTH: 0.6095
G1 X135.536 Y135.108 E.04685
; LINE_WIDTH: 0.56869
G1 X135.018 Y134.969 E.05493
; LINE_WIDTH: 0.528624
G1 X134.495 Y134.828 E.05052
; LINE_WIDTH: 0.484142
G1 X133.486 Y134.542 E.08704
; LINE_WIDTH: 0.445242
G1 X128.907 Y133.136 E.35528
; WIPE_START
G1 X130.819 Y133.723 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.207 Y128.55 Z15.36 F42000
G1 X123.174 Y126.675 Z15.36
G1 Z14.96
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X125.848 Y125.848 E.44698
G1 X127.962 Y127.962 E.47743
G1 X127.962 Y128.038 E.01201
G1 X125.848 Y130.152 E.47743
G1 X123.174 Y129.325 E.44698
M204 S10000
G1 X120.495 Y129.418 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.18008
G1 F2122.842
M204 S6000
G1 X127.563 Y131.602 E1.78904
M204 S10000
G1 X120.495 Y126.582 F42000
; LINE_WIDTH: 1.18007
G1 F2122.862
M204 S6000
G1 X127.563 Y124.398 E1.78903
; CHANGE_LAYER
; Z_HEIGHT: 15.52
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F2122.862
G1 X125.652 Y124.988 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 28/51
; update layer progress
M73 L28
M991 S0 P27 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z15.52 I.637 J1.58 P1  F42000
G1 X128.375 Y123.89 Z15.52
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.375 Y132.242 E1.33365
G1 X119.615 Y129.535 E1.4641
G1 X119.615 Y126.465 E.49012
G1 X128.375 Y123.758 E1.4641
G1 X128.375 Y123.77 E.00183
; WIPE_START
G1 X128.375 Y125.77 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.411 Y123.467 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X129.075 Y123.88 E.22328
G1 X129.075 Y132.12 E1.31562
G1 X134.401 Y133.766 E.89011
G2 X142.924 Y135.402 I12.815 J-43.716 E1.38788
G2 X144.415 Y135.537 I4.974 J-46.619 E.23908
G1 X144.399 Y135.94 E.06435
G1 X137.973 Y135.94 E1.02604
G1 X118.915 Y130.051 E3.18507
G1 X118.915 Y125.949 E.65497
G1 X137.973 Y120.06 E3.18506
G1 X144.397 Y120.06 E1.02571
G1 X144.413 Y120.462 E.0643
G2 X135.329 Y121.964 I3.53 J49.581 E1.47241
G1 X134.401 Y122.235 E.15435
G1 X130.526 Y123.432 E.6476
; WIPE_START
G1 X129.075 Y123.88 E-.57696
G1 X129.075 Y124.362 E-.18304
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.038 Y124.315 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.775 Y124.397 E.04395
G1 X129.775 Y131.603 E1.15077
G1 X130.038 Y131.685 E.04395
G1 F2250
G1 X130.611 Y131.862 E.0958
G1 F2100
G1 X131.295 Y132.073 E.11423
G1 F1800
G1 X131.978 Y132.284 E.11423
G1 F1650
G1 X132.662 Y132.495 E.11423
G1 F1500
G1 X133.345 Y132.707 E.11423
M106 S201.45
M106 S255
G1 F1380
G1 X134.602 Y133.095 E.21003
M106 S201.45
G1 F1650
G1 X135.53 Y133.366 E.1544
G1 F1950
G1 X136.504 Y133.618 E.16065
M106 S255
G1 F2400
G1 X137.517 Y133.85 E.16594
G1 F2700
G1 X138.563 Y134.063 E.17039
G1 F2850
G1 X139.025 Y134.147 E.07506
G1 F3000
G1 X139.639 Y134.255 E.09949
G1 F3215.099
G1 X140.177 Y134.34 E.08693
G1 X140.739 Y134.426 E.09088
G1 X141.356 Y134.511 E.09941
G1 X141.86 Y134.577 E.08119
G1 X142.558 Y134.659 E.11223
G1 X142.996 Y134.706 E.07034
G1 X143.78 Y134.783 E.12583
G1 X144.378 Y134.832 E.0958
G1 X144.415 Y134.835 E.00585
G1 X145.013 Y134.884 E.0958
G1 X145.859 Y134.937 E.13534
G2 X148.78 Y135.05 I8.937 J-193.91 E.46678
G1 X148.78 Y136.64 E.25387
G1 X137.867 Y136.64 E1.74249
G1 X118.215 Y130.567 E3.28436
G1 X118.215 Y125.433 E.81982
G1 X137.867 Y119.36 E3.28436
G1 X148.78 Y119.36 E1.74249
G1 X148.78 Y120.951 E.25404
G2 X145.838 Y121.063 I4.923 J167.767 E.47004
G1 X144.895 Y121.124 E.15094
G1 X144.297 Y121.174 E.09581
G1 X144.271 Y121.176 E.00424
G1 X143.673 Y121.226 E.09581
G1 X143.076 Y121.288 E.0958
G1 X143.062 Y121.29 E.0023
G1 X142.465 Y121.351 E.0958
G1 X141.778 Y121.434 E.11045
G1 X141.272 Y121.5 E.08151
G1 X140.667 Y121.585 E.0975
G1 X140.104 Y121.671 E.09103
G1 X139.576 Y121.756 E.08537
G1 F3000
G1 X138.962 Y121.864 E.09948
M73 P82 R3
G1 F2850
G1 X138.509 Y121.948 E.07366
G1 F2700
G1 X137.471 Y122.16 E.16904
G1 F2250
G1 X136.467 Y122.392 E.16468
G1 F1950
G1 X135.515 Y122.639 E.15701
M73 P82 R2
G1 F1650
G1 X134.602 Y122.905 E.15186
G1 F1380
G1 X134.028 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1500
G1 X133.345 Y123.293 E.11422
M106 S201.45
G1 F1650
G1 X132.662 Y123.505 E.11423
G1 F1800
G1 X131.978 Y123.716 E.11422
G1 F2100
G1 X131.295 Y123.927 E.11423
G1 F2250
G1 X130.153 Y124.28 E.19087
; WIPE_START
M204 S6000
G1 X129.775 Y124.397 E-.15018
G1 X129.775 Y126.001 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z15.92 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z15.92
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z15.92 F4000
            G39.3 S1
            G0 Z15.92 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X128.725 Y123.453 F42000
G1 Z15.52
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444659
G1 F3000
M204 S6000
G1 X135.188 Y121.464 E.50063
; LINE_WIDTH: 0.482316
G1 X136.168 Y121.185 E.08417
; LINE_WIDTH: 0.525009
G1 X136.685 Y121.046 E.04943
; LINE_WIDTH: 0.563822
G1 X137.196 Y120.908 E.05364
; LINE_WIDTH: 0.583371
G1 X137.202 Y120.907 E.00062
; LINE_WIDTH: 0.631882
G1 X138.067 Y120.685 E.10428
G1 X138.257 Y120.666 E.02227
; LINE_WIDTH: 0.610809
G1 X138.499 Y120.644 E.02723
; LINE_WIDTH: 0.566808
G1 X138.737 Y120.622 E.0243
; LINE_WIDTH: 0.526395
G1 X138.95 Y120.604 E.01986
; LINE_WIDTH: 0.489298
G1 X139.162 Y120.585 E.01789
; LINE_WIDTH: 0.452365
G1 X139.374 Y120.567 E.0161
; LINE_WIDTH: 0.411662
G1 X139.65 Y120.544 E.01841
; LINE_WIDTH: 0.367404
G1 X139.923 Y120.522 E.01549
; LINE_WIDTH: 0.32421
G1 X140.227 Y120.5 E.01417
; LINE_WIDTH: 0.282035
G1 X140.529 Y120.478 E.01118
; LINE_WIDTH: 0.239967
G1 X140.831 Y120.455 E.00828
; WIPE_START
G1 X140.529 Y120.478 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.755 Y120.247 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 1.14604
G1 F2193.283
M204 S6000
G1 X145.413 Y120.225 E.15424
; LINE_WIDTH: 1.11976
G1 F2250.948
G1 X146.072 Y120.203 E.15029
; LINE_WIDTH: 1.09196
G1 F2315.321
G1 X146.702 Y120.189 E.13963
; LINE_WIDTH: 1.0631
G1 F2386.185
G1 X147.321 Y120.174 E.1334
; LINE_WIDTH: 1.03946
G1 F2447.573
G1 X148.43 Y120.159 E.23255
; WIPE_START
G1 X147.321 Y120.174 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.86 Y127.788 Z15.92 F42000
G1 X148.43 Y135.841 Z15.92
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 1.03692
G1 F2454.335
M204 S6000
G1 X147.464 Y135.828 E.20211
; LINE_WIDTH: 1.05755
G1 F2400.335
G1 X146.839 Y135.814 E.13379
; LINE_WIDTH: 1.08541
G1 F2331.054
G1 X146.204 Y135.8 E.13976
; LINE_WIDTH: 1.1141
G1 F2263.765
G1 X145.48 Y135.778 E.16421
; LINE_WIDTH: 1.14326
G1 F2199.245
G1 X144.757 Y135.755 E.16902
; WIPE_START
G1 X145.48 Y135.778 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.83 Y135.544 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 0.232468
G1 F3000
M204 S6000
G1 X140.578 Y135.527 E.00646
; LINE_WIDTH: 0.268271
G1 X140.289 Y135.505 E.0098
; LINE_WIDTH: 0.312114
G1 X139.999 Y135.483 E.01274
; LINE_WIDTH: 0.356127
G1 X139.72 Y135.461 E.01505
; LINE_WIDTH: 0.40042
G1 X139.439 Y135.439 E.01803
; LINE_WIDTH: 0.441154
G1 X139.228 Y135.421 E.01555
; LINE_WIDTH: 0.478068
G1 X139.016 Y135.402 E.01734
; LINE_WIDTH: 0.515091
G1 X138.803 Y135.384 E.01925
; LINE_WIDTH: 0.555454
G1 X138.562 Y135.362 E.02409
; LINE_WIDTH: 0.599509
G1 X138.315 Y135.339 E.02708
; LINE_WIDTH: 0.633485
G1 X138.067 Y135.315 E.02916
G1 X137.248 Y135.105 E.09901
; LINE_WIDTH: 0.587329
G1 X137.243 Y135.104 E.00063
; LINE_WIDTH: 0.567342
G1 X136.727 Y134.965 E.05446
; LINE_WIDTH: 0.527677
G1 X136.206 Y134.825 E.05013
; LINE_WIDTH: 0.483683
G1 X135.204 Y134.541 E.0864
; LINE_WIDTH: 0.44472
G1 X128.725 Y132.547 E.50196
; WIPE_START
G1 X130.637 Y133.135 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.085 Y129.22 Z15.92 F42000
G1 X123.581 Y128.919 Z15.92
G1 Z15.52
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X126.255 Y129.745 E.44698
G1 X127.78 Y128.22 E.34446
G1 X127.78 Y127.78 E.07011
G1 X126.255 Y126.255 E.34446
G1 X123.581 Y127.081 E.44698
M204 S10000
G1 X120.495 Y128.886 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.17997
G1 F2123.062
M204 S6000
G1 X127.381 Y131.014 E1.74284
M204 S10000
G1 X127.495 Y124.951 F42000
; LINE_WIDTH: 1.18
G1 F2123.002
M204 S6000
G1 X120.609 Y127.079 E1.74288
; CHANGE_LAYER
; Z_HEIGHT: 16.08
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2123.002
G1 X122.52 Y126.488 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 29/51
; update layer progress
M73 L29
M991 S0 P28 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z16.08 I.341 J1.669 P1  F42000
G1 X128.193 Y125.329 Z16.08
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.193 Y131.653 E1.00983
G1 X119.615 Y129.002 E1.43369
G1 X119.615 Y126.998 E.32004
G1 X128.193 Y124.347 E1.43369
G1 X128.193 Y125.209 E.13761
M204 S10000
G1 X128.893 Y125.083 F42000
M106 S255
G1 F3215.099
M204 S6000
G1 X128.893 Y131.531 E1.02958
G1 X136.124 Y133.765 E1.20849
G2 X144.272 Y135.362 I12.714 J-43.296 E1.32768
G2 X146.135 Y135.537 I5.398 J-47.365 E.29873
G1 X146.119 Y135.94 E.06438
G1 X139.696 Y135.94 E1.02546
G1 X118.915 Y129.518 E3.47311
G1 X118.915 Y126.482 E.48489
G1 X139.696 Y120.06 E3.47311
G1 X146.119 Y120.06 E1.02547
G1 X146.135 Y120.462 E.06432
G2 X137.042 Y121.967 I3.683 J50.492 E1.47384
G1 X136.124 Y122.235 E.15259
G1 X128.893 Y124.469 E1.20848
G1 X128.893 Y124.963 E.07883
M204 S250
G1 X129.856 Y124.904 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.593 Y124.985 E.04394
G1 X129.593 Y131.015 E.96273
G1 X129.856 Y131.096 E.04394
G1 F2250
G1 X130.429 Y131.273 E.0958
G1 F2100
G1 X131.021 Y131.456 E.09884
G1 F1950
G1 X132.203 Y131.821 E.19769
G1 F1800
G1 X132.795 Y132.004 E.09884
G1 F1650
G1 X133.978 Y132.37 E.19769
G1 F1500
G1 X135.161 Y132.735 E.19769
M106 S201.45
M106 S255
G1 F1380
G1 X136.325 Y133.095 E.19465
M106 S201.45
M106 S255
G1 F1650
G1 X137.248 Y133.364 E.15354
G1 F1950
G1 X138.217 Y133.615 E.15971
G1 F2250
G1 X139.223 Y133.847 E.16485
G1 F2550
G1 X139.712 Y133.947 E.07981
G1 F2700
G1 X140.263 Y134.058 E.08969
G1 F2850
G1 X140.827 Y134.161 E.09151
G1 F3000
G1 X141.332 Y134.25 E.08186
G1 F3215.099
G1 X141.974 Y134.352 E.10389
G1 X142.425 Y134.421 E.07276
G1 X143.149 Y134.52 E.11678
G1 X143.538 Y134.571 E.06263
G1 X144.348 Y134.666 E.13019
G1 X144.945 Y134.726 E.0958
G1 X144.966 Y134.729 E.00331
G1 X145.562 Y134.789 E.0958
G1 X146.161 Y134.837 E.09581
G1 X146.191 Y134.84 E.00495
G1 X146.79 Y134.888 E.09581
G1 X147.611 Y134.939 E.13138
G2 X148.78 Y134.998 I2.179 J-31.759 E.18695
G1 X148.78 Y136.64 E.26221
G1 X139.591 Y136.64 E1.46729
G1 X118.215 Y130.035 E3.5724
G1 X118.215 Y125.965 E.64974
G1 X139.591 Y119.36 E3.5724
G1 X148.78 Y119.36 E1.46729
G1 X148.78 Y121.002 E.26226
G2 X147.569 Y121.063 I.955 J31.404 E.19367
G1 X146.656 Y121.121 E.14602
G1 X146.058 Y121.171 E.0958
G1 X146.038 Y121.173 E.00319
G1 X145.44 Y121.222 E.0958
G1 X144.843 Y121.284 E.09581
G1 X144.835 Y121.284 E.00134
G1 X144.238 Y121.346 E.09581
G1 X143.443 Y121.441 E.12785
G1 X143.051 Y121.492 E.06323
G1 X142.34 Y121.592 E.11456
G1 X141.887 Y121.661 E.07315
G1 X141.256 Y121.763 E.10202
G1 F3000
G1 X140.75 Y121.852 E.0821
G1 F2850
G1 X140.197 Y121.955 E.08977
M73 P83 R2
G1 F2700
G1 X139.646 Y122.066 E.08981
G1 F2550
G1 X139.165 Y122.166 E.0784
G1 F2250
G1 X138.168 Y122.397 E.16347
G1 F1950
G1 X137.228 Y122.642 E.15512
G1 F1650
G1 X136.325 Y122.905 E.1501
G1 F1380
G1 X135.752 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1500
G1 X134.569 Y123.448 E.19768
M106 S201.45
G1 F1650
G1 X133.386 Y123.813 E.19768
G1 F1800
G1 X132.795 Y123.996 E.09884
G1 F1950
G1 X131.612 Y124.361 E.19768
G1 F2100
G1 X131.021 Y124.544 E.09884
G1 F2250
G1 X129.971 Y124.869 E.17549
; WIPE_START
M204 S6000
G1 X129.593 Y124.985 E-.15018
G1 X129.593 Y126.59 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z16.48 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z16.48
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z16.48 F4000
            G39.3 S1
            G0 Z16.48 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X127.493 Y128 F42000
G1 Z16.08
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X127.493 Y125.296 E.43181
G1 X120.315 Y127.514 E1.19977
G1 X120.315 Y128.486 E.15518
G1 X127.493 Y130.704 E1.19977
G1 X127.493 Y128.12 E.41265
M204 S10000
G1 X126.794 Y128 F42000
G1 F3215.112
M204 S6000
G1 X126.794 Y126.244 E.28032
G1 X121.112 Y128 E.94948
G1 X126.794 Y129.756 E.94948
G1 X126.794 Y128.12 E.26116
M204 S10000
G1 X125.971 Y128 F42000
; LINE_WIDTH: 1.06528
G1 F2380.701
M204 S6000
G1 X125.971 Y127.359 E.13814
G1 X123.898 Y128 E.4679
G1 X125.971 Y128.641 E.4679
G1 X125.971 Y128.12 E.11227
; WIPE_START
G1 X125.971 Y128.641 E-.19784
G1 X124.558 Y128.204 E-.56216
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.543 Y131.958 Z16.48 F42000
G1 Z16.08
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444439
G1 F3000
M204 S6000
G1 X136.922 Y134.539 E.64865
; LINE_WIDTH: 0.483248
G1 X137.919 Y134.822 E.08582
; LINE_WIDTH: 0.526746
G1 X138.435 Y134.961 E.04963
; LINE_WIDTH: 0.565906
G1 X138.947 Y135.099 E.05387
; LINE_WIDTH: 0.585634
G1 X138.952 Y135.1 E.00063
; LINE_WIDTH: 0.632842
G1 X139.791 Y135.315 E.10123
G1 X140.015 Y135.337 E.02633
; LINE_WIDTH: 0.608145
G1 X140.216 Y135.355 E.02243
; LINE_WIDTH: 0.572408
G1 X140.411 Y135.373 E.02024
; LINE_WIDTH: 0.537147
G1 X140.606 Y135.391 E.01867
; LINE_WIDTH: 0.496559
G1 X140.869 Y135.414 E.02268
; LINE_WIDTH: 0.45075
G1 X141.131 Y135.436 E.01983
; LINE_WIDTH: 0.410169
G1 X141.355 Y135.454 E.01485
; LINE_WIDTH: 0.374952
G1 X141.576 Y135.472 E.0129
; LINE_WIDTH: 0.339929
G1 X141.798 Y135.489 E.01113
; LINE_WIDTH: 0.304757
G1 X142.031 Y135.507 E.00985
; LINE_WIDTH: 0.269513
G1 X142.263 Y135.524 E.00795
; LINE_WIDTH: 0.235237
G1 X142.555 Y135.544 E.00768
; WIPE_START
G1 X142.263 Y135.524 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.476 Y135.755 Z16.48 F42000
G1 Z16.08
G1 E.8 F1800
; LINE_WIDTH: 1.14299
G1 F2199.811
M204 S6000
G1 X147.209 Y135.778 E.17094
; LINE_WIDTH: 1.11368
G1 F2264.725
G1 X147.941 Y135.801 E.16604
; LINE_WIDTH: 1.08099
G1 F2341.758
G1 X147.959 Y135.784 E.00542
; LINE_WIDTH: 1.04496
G1 F2433.014
G1 X147.977 Y135.767 E.00522
; LINE_WIDTH: 1.01826
G1 F2505.344
G1 X148.43 Y135.337 E.12802
; WIPE_START
G1 X147.977 Y135.767 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.43 Y128.572 Z16.48 F42000
G1 X142.556 Y120.455 Z16.48
G1 Z16.08
G1 E.8 F1800
; LINE_WIDTH: 0.238346
G1 F3000
M204 S6000
G1 X142.274 Y120.476 E.00764
; LINE_WIDTH: 0.277255
G1 X141.992 Y120.497 E.01015
; LINE_WIDTH: 0.316272
G1 X141.708 Y120.518 E.01274
; LINE_WIDTH: 0.35337
G1 X141.49 Y120.535 E.0116
; LINE_WIDTH: 0.388357
G1 X141.273 Y120.553 E.01334
; LINE_WIDTH: 0.423516
G1 X141.054 Y120.57 E.01523
; LINE_WIDTH: 0.464156
G1 X140.791 Y120.593 E.02072
; LINE_WIDTH: 0.510209
G1 X140.526 Y120.616 E.02366
; LINE_WIDTH: 0.550906
G1 X140.334 Y120.634 E.01892
; LINE_WIDTH: 0.586062
G1 X140.142 Y120.651 E.02046
; LINE_WIDTH: 0.621679
G1 X139.946 Y120.669 E.0226
; LINE_WIDTH: 0.655469
G1 X139.791 Y120.685 E.019
; LINE_WIDTH: 0.648573
G1 X139.342 Y120.8 E.05587
; LINE_WIDTH: 0.603124
G1 X138.888 Y120.917 E.0517
; LINE_WIDTH: 0.561375
G1 X138.381 Y121.054 E.05285
; LINE_WIDTH: 0.523273
G1 X137.869 Y121.192 E.04876
; LINE_WIDTH: 0.481457
G1 X136.901 Y121.467 E.08292
; LINE_WIDTH: 0.444385
G1 X128.543 Y124.042 E.64692
; CHANGE_LAYER
; Z_HEIGHT: 16.64
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X130.455 Y123.453 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 30/51
; update layer progress
M73 L30
M991 S0 P29 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z16.64 I-.94 J-1.421 P1  F42000
G1 X128.011 Y125.07 Z16.64
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.011 Y131.064 E.95716
G1 X119.615 Y128.47 E1.40328
G1 X119.615 Y127.53 E.14995
G1 X128.011 Y124.936 E1.40328
G1 X128.011 Y124.95 E.00225
; WIPE_START
G1 X128.011 Y126.95 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.044 Y124.646 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X128.711 Y125.058 E.2227
G1 X128.711 Y130.942 E.93954
G1 X137.847 Y133.765 E1.52684
G2 X145.13 Y135.26 I12.538 J-42.602 E1.18848
G2 X147.853 Y135.537 I8.304 J-68.062 E.43717
G1 X147.837 Y135.94 E.06441
G1 X141.42 Y135.94 E1.02468
G1 X118.915 Y128.986 E3.76114
G1 X118.915 Y127.014 E.31481
G1 X141.42 Y120.06 E3.76115
G1 X147.84 Y120.06 E1.02514
G1 X147.857 Y120.462 E.06434
G2 X138.753 Y121.97 I3.708 J50.619 E1.47554
G1 X137.847 Y122.235 E.15056
G1 X130.158 Y124.611 E1.28505
; WIPE_START
G1 X128.711 Y125.058 E-.57558
G1 X128.711 Y125.543 E-.18443
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.674 Y125.493 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.411 Y125.574 E.04395
G1 X129.411 Y130.426 E.77469
G1 X129.674 Y130.507 E.04395
G1 F2250
G1 X130.247 Y130.684 E.0958
G1 F2100
G1 X131.05 Y130.932 E.13422
G1 F1950
G1 X132.657 Y131.429 E.26844
G1 F1800
G1 X133.46 Y131.677 E.13422
G1 F1650
G1 X135.066 Y132.173 E.26844
G1 F1500
G1 X136.672 Y132.67 E.26844
M106 S201.45
M106 S255
G1 F1380
G1 X138.049 Y133.095 E.23003
M106 S201.45
M106 S255
G1 F1650
G1 X138.966 Y133.363 E.15266
G1 F1950
G1 X139.411 Y133.479 E.07338
G1 F2100
G1 X139.929 Y133.612 E.08547
G1 F2250
G1 X140.93 Y133.843 E.16388
G1 F2700
G1 X141.963 Y134.054 E.16836
G1 F3000
G1 X143.024 Y134.244 E.17222
G1 F3215.099
G1 X144.109 Y134.415 E.17538
G1 X144.942 Y134.53 E.1343
G1 X145.216 Y134.565 E.04407
G1 X146.136 Y134.674 E.14793
G1 X146.733 Y134.733 E.0958
G1 X146.748 Y134.735 E.0024
G1 X147.345 Y134.794 E.0958
G1 X147.943 Y134.842 E.09581
G1 X147.968 Y134.844 E.00394
G1 X148.566 Y134.892 E.09581
G1 X148.78 Y134.905 E.03424
G1 X148.78 Y134.917 E.00182
G1 X148.78 Y136.64 E.27515
G1 X141.314 Y136.64 E1.19209
G1 X118.215 Y129.502 E3.86044
G1 X118.215 Y126.498 E.47966
G1 X141.314 Y119.36 E3.86044
G1 X148.78 Y119.36 E1.19209
G1 X148.78 Y121.084 E.27521
G1 X148.78 Y121.095 E.00188
G1 X148.417 Y121.118 E.05807
G1 X147.819 Y121.168 E.0958
G1 X147.806 Y121.169 E.00215
G1 X147.208 Y121.218 E.0958
G1 X146.611 Y121.279 E.09581
G1 X146.608 Y121.279 E.00047
G1 X146.011 Y121.34 E.09581
G1 X144.831 Y121.485 E.18989
G1 X144.012 Y121.6 E.13206
G1 X142.936 Y121.771 E.17382
G1 F3000
G1 X141.885 Y121.962 E.17066
G1 F2550
G1 X140.861 Y122.172 E.16696
G1 F2250
G1 X139.87 Y122.402 E.16246
G1 F2100
M73 P84 R2
G1 X139.351 Y122.536 E.08551
G1 F1950
G1 X138.94 Y122.645 E.06789
G1 F1650
G1 X138.049 Y122.905 E.14826
G1 F1380
G1 X137.475 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1500
G1 X135.869 Y123.578 E.26845
M106 S201.45
G1 F1650
G1 X134.263 Y124.075 E.26845
G1 F1800
G1 X133.46 Y124.323 E.13422
G1 F1950
G1 X131.853 Y124.819 E.26845
G1 F2100
G1 X131.05 Y125.068 E.13422
G1 F2250
G1 X129.789 Y125.457 E.21087
; WIPE_START
M204 S6000
G1 X129.411 Y125.574 E-.15018
G1 X129.411 Y127.179 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z17.04 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z17.04
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z17.04 F4000
            G39.3 S1
            G0 Z17.04 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X128.361 Y124.631 F42000
G1 Z16.64
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444216
G1 F3000
M204 S6000
G1 X138.612 Y121.471 E.79304
; LINE_WIDTH: 0.480663
G1 X139.571 Y121.198 E.08205
; LINE_WIDTH: 0.52174
G1 X140.08 Y121.06 E.0483
; LINE_WIDTH: 0.559281
G1 X140.584 Y120.924 E.05231
; LINE_WIDTH: 0.601256
G1 X141.052 Y120.804 E.05302
; LINE_WIDTH: 0.64769
G1 X141.514 Y120.685 E.05744
; LINE_WIDTH: 0.658126
G1 X141.639 Y120.672 E.01532
; LINE_WIDTH: 0.620968
G1 X141.912 Y120.648 E.03133
; LINE_WIDTH: 0.571789
G1 X142.185 Y120.623 E.02826
; LINE_WIDTH: 0.52261
G1 X142.458 Y120.599 E.02518
; LINE_WIDTH: 0.473431
G1 X142.731 Y120.574 E.0221
; LINE_WIDTH: 0.426616
G1 X143.012 Y120.552 E.0197
; LINE_WIDTH: 0.382521
G1 X143.289 Y120.53 E.01665
; LINE_WIDTH: 0.33871
G1 X143.567 Y120.508 E.01387
; LINE_WIDTH: 0.294899
G1 X143.844 Y120.486 E.01109
; LINE_WIDTH: 0.259326
G1 X144.064 Y120.471 E.00699
; LINE_WIDTH: 0.232127
G1 X144.282 Y120.455 E.00559
; WIPE_START
G1 X144.064 Y120.471 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.325 Y120.775 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.351872
G1 F3000
M204 S6000
G1 X148.303 Y119.71 E.05631
; WIPE_START
G1 X148.325 Y120.775 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.324 Y128.407 Z17.04 F42000
G1 X148.323 Y135.224 Z17.04
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.355012
G1 F3000
M204 S6000
G1 X148.302 Y136.29 E.05715
; WIPE_START
G1 X148.323 Y135.224 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.281 Y135.544 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.238248
G1 F3000
M204 S6000
G1 X143.945 Y135.521 E.00907
; LINE_WIDTH: 0.279798
G1 X143.665 Y135.5 E.01022
; LINE_WIDTH: 0.323479
G1 X143.385 Y135.478 E.01302
; LINE_WIDTH: 0.367161
G1 X143.106 Y135.456 E.01581
; LINE_WIDTH: 0.411111
G1 X142.822 Y135.434 E.01885
; LINE_WIDTH: 0.457819
G1 X142.547 Y135.409 E.02131
; LINE_WIDTH: 0.506942
G1 X142.271 Y135.385 E.02442
; LINE_WIDTH: 0.556065
G1 X141.996 Y135.36 E.02752
; LINE_WIDTH: 0.605188
G1 X141.72 Y135.335 E.03062
; LINE_WIDTH: 0.650461
G1 X141.514 Y135.315 E.02501
; LINE_WIDTH: 0.649521
G1 X141.087 Y135.205 E.05327
; LINE_WIDTH: 0.60584
G1 X140.654 Y135.095 E.04952
; LINE_WIDTH: 0.564648
G1 X140.146 Y134.958 E.0534
; LINE_WIDTH: 0.525918
G1 X139.632 Y134.819 E.04922
; LINE_WIDTH: 0.482539
G1 X138.639 Y134.537 E.08535
; LINE_WIDTH: 0.44426
G1 X128.361 Y131.369 E.79528
; WIPE_START
G1 X130.273 Y131.958 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.815 Y127.889 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.1417
G1 F2202.6
M204 S6000
G1 X125.687 Y127.889 E.02976
G1 X125.623 Y128 E.02976
G1 X125.687 Y128.111 E.02976
G1 X125.819 Y128.104 E.0307
M204 S10000
G1 X126.612 Y128 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X126.612 Y126.833 E.1863
G1 X122.836 Y128 E.63103
G1 X126.612 Y129.167 E.63102
G1 X126.612 Y128.12 E.16715
M204 S10000
G1 X127.312 Y128 F42000
G1 F3215.112
M204 S6000
G1 X127.312 Y125.884 E.33779
G1 X120.466 Y128 E1.14412
G1 X127.312 Y130.115 E1.14412
G1 X127.312 Y128.12 E.31863
; CHANGE_LAYER
; Z_HEIGHT: 17.2
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.112
G1 X127.312 Y130.115 E-.7583
G1 X127.307 Y130.114 E-.0017
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 31/51
; update layer progress
M73 L31
M991 S0 P30 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z17.2 I1.686 J.244 P1  F42000
G1 X127.829 Y126.502 Z17.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X127.829 Y130.475 E.63438
G1 X120.32 Y128.155 E1.25503
G1 X120.32 Y127.845 E.04945
G1 X127.829 Y125.525 E1.25503
G1 X127.829 Y126.382 E.13698
M204 S10000
G1 X128.529 Y126.259 F42000
M106 S255
G1 F3215.099
M204 S6000
G1 X128.529 Y130.353 E.65377
G1 X139.571 Y133.765 E1.84536
G2 X146.805 Y135.254 I12.523 J-42.536 E1.18067
G1 X148.08 Y135.403 E.20498
G1 X148.08 Y135.94 E.08577
G1 X143.143 Y135.94 E.78827
G1 X118.915 Y128.453 E4.04919
G1 X118.915 Y127.547 E.14472
G1 X143.143 Y120.06 E4.04919
G1 X148.08 Y120.06 E.78827
G1 X148.08 Y120.601 E.08643
G2 X140.467 Y121.973 I4.602 J47.348 E1.2366
G1 X139.571 Y122.235 E.14903
G1 X128.529 Y125.647 E1.84535
G1 X128.529 Y126.139 E.07857
M204 S250
G1 X129.492 Y126.082 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.229 Y126.163 E.04394
G1 X129.229 Y129.837 E.58665
G1 X129.492 Y129.918 E.04394
G1 F2250
G1 X130.065 Y130.095 E.0958
G1 F2100
G1 X131.08 Y130.409 E.16961
G1 F1950
G1 X133.11 Y131.036 E.33922
G1 F1800
G1 X134.125 Y131.35 E.16961
G1 F1650
G1 X136.154 Y131.977 E.33922
G1 F1500
G1 X138.184 Y132.604 E.33922
M106 S201.45
M106 S255
G1 F1380
G1 X139.772 Y133.095 E.26541
M106 S201.45
M106 S255
G1 F1650
G1 X140.685 Y133.361 E.1518
G1 F1950
G1 X141.642 Y133.61 E.15783
G1 F2250
G1 X142.636 Y133.839 E.16291
G1 F2700
G1 X143.662 Y134.049 E.16729
G1 F3000
G1 X144.716 Y134.239 E.17105
G1 F3215.099
G1 X145.57 Y134.375 E.13796
G1 X145.796 Y134.41 E.03654
G1 X146.893 Y134.56 E.17679
G1 X148.005 Y134.69 E.17884
G1 X148.78 Y134.765 E.12429
G1 X148.78 Y134.824 E.0094
G1 X148.78 Y136.64 E.28993
G1 X143.038 Y136.64 E.91689
G1 X118.215 Y128.969 E4.14848
G1 X118.215 Y127.031 E.30957
G1 X143.038 Y119.36 E4.14848
G1 X148.78 Y119.36 E.91689
G1 X148.78 Y121.176 E.29005
G1 X148.78 Y121.234 E.00913
G1 X147.784 Y121.334 E.15978
G1 X146.609 Y121.477 E.18906
G1 X145.456 Y121.642 E.186
G1 X144.616 Y121.778 E.13583
G1 F2850
G1 X143.572 Y121.968 E.16941
G1 F2550
G1 X142.555 Y122.179 E.16583
G1 F2250
G1 X141.571 Y122.408 E.16146
G1 F1950
G1 X140.653 Y122.648 E.15135
G1 F1650
G1 X139.772 Y122.905 E.1466
G1 F1380
G1 X138.184 Y123.396 E.26541
M106 S201.45
M106 S255
G1 F1500
G1 X137.169 Y123.709 E.16961
M106 S201.45
G1 F1650
G1 X135.139 Y124.337 E.33921
G1 F1800
G1 X134.125 Y124.65 E.16961
G1 F1950
G1 X132.095 Y125.277 E.33921
G1 F2100
G1 X131.08 Y125.591 E.16961
G1 F2250
G1 X129.607 Y126.046 E.24625
; WIPE_START
M204 S6000
G1 X129.229 Y126.163 E-.15018
G1 X129.229 Y127.768 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z17.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
M73 P85 R2
G1 Z17.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z17.6 F4000
            G39.3 S1
            G0 Z17.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X127.13 Y128 F42000
G1 Z17.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X127.13 Y126.473 E.24377
G1 X122.189 Y128 E.82567
G1 X127.13 Y129.527 E.82568
G1 X127.13 Y128.12 E.22461
M204 S10000
G1 X126.392 Y128 F42000
; LINE_WIDTH: 0.896427
G1 F2898.551
M204 S6000
G1 X126.392 Y127.474 E.09319
G1 X124.689 Y128 E.31564
G1 X126.392 Y128.526 E.31565
G1 X126.392 Y128.12 E.07194
; WIPE_START
G1 X126.392 Y128.526 E-.15434
G1 X124.869 Y128.056 E-.60566
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.179 Y130.781 Z17.6 F42000
G1 Z17.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444137
G1 F3000
M204 S6000
G1 X140.358 Y134.536 E.94204
; LINE_WIDTH: 0.482377
G1 X141.343 Y134.816 E.08461
; LINE_WIDTH: 0.524945
G1 X141.854 Y134.954 E.0489
; LINE_WIDTH: 0.563313
G1 X142.361 Y135.09 E.05301
; LINE_WIDTH: 0.604641
G1 X142.802 Y135.203 E.05037
; LINE_WIDTH: 0.648972
G1 X143.238 Y135.315 E.05428
; LINE_WIDTH: 0.652719
G1 X143.418 Y135.333 E.02205
; LINE_WIDTH: 0.610066
G1 X143.692 Y135.358 E.03068
; LINE_WIDTH: 0.561155
G1 X143.965 Y135.382 E.02762
; LINE_WIDTH: 0.512244
G1 X144.239 Y135.406 E.02456
; LINE_WIDTH: 0.463333
G1 X144.512 Y135.431 E.02149
; LINE_WIDTH: 0.415411
G1 X144.808 Y135.454 E.02
; LINE_WIDTH: 0.368819
G1 X145.101 Y135.478 E.01666
; LINE_WIDTH: 0.322484
G1 X145.394 Y135.501 E.01355
; LINE_WIDTH: 0.279135
G1 X145.702 Y135.523 E.01121
; LINE_WIDTH: 0.238931
G1 X146.008 Y135.544 E.00833
; WIPE_START
G1 X145.702 Y135.523 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.861 Y127.892 Z17.6 F42000
G1 X146.015 Y120.455 Z17.6
G1 Z17.2
G1 E.8 F1800
; LINE_WIDTH: 0.242795
G1 F3000
M204 S6000
G1 X145.65 Y120.481 E.01025
; LINE_WIDTH: 0.291372
G1 X145.283 Y120.507 E.01438
; LINE_WIDTH: 0.339145
G1 X144.992 Y120.531 E.01457
; LINE_WIDTH: 0.385958
G1 X144.702 Y120.554 E.01768
; LINE_WIDTH: 0.433037
G1 X144.408 Y120.578 E.02105
; LINE_WIDTH: 0.481253
G1 X144.137 Y120.603 E.02241
; LINE_WIDTH: 0.530277
G1 X143.866 Y120.627 E.02546
; LINE_WIDTH: 0.579301
G1 X143.595 Y120.652 E.0285
; LINE_WIDTH: 0.628325
G1 X143.324 Y120.676 E.03154
; LINE_WIDTH: 0.661566
G1 X143.238 Y120.685 E.01068
; LINE_WIDTH: 0.646735
G1 X142.761 Y120.807 E.05915
; LINE_WIDTH: 0.599238
G1 X142.279 Y120.932 E.05444
; LINE_WIDTH: 0.556994
G1 X141.777 Y121.067 E.0518
; LINE_WIDTH: 0.519997
G1 X141.27 Y121.204 E.04787
; LINE_WIDTH: 0.479764
G1 X140.326 Y121.473 E.08053
; LINE_WIDTH: 0.444073
G1 X128.179 Y125.219 E.9394
; CHANGE_LAYER
; Z_HEIGHT: 17.76
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X130.091 Y124.63 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 32/51
; update layer progress
M73 L32
M991 S0 P31 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z17.76 I-.943 J-1.419 P1  F42000
G1 X127.647 Y126.254 Z17.76
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X127.647 Y129.887 E.57998
G1 X122.043 Y128.155 E.93658
G1 X122.043 Y127.845 E.04945
G1 X127.647 Y126.113 E.93658
G1 X127.647 Y126.134 E.00335
; WIPE_START
G1 X127.647 Y128.134 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.67 Y125.827 Z18.16 F42000
G1 Z17.76
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X128.347 Y126.236 E.22113
G1 X128.347 Y129.764 E.56346
G1 X141.295 Y133.765 E2.16387
G2 X148.08 Y135.193 I12.018 J-40.295 E1.10841
G1 X148.08 Y135.94 E.11937
G1 X144.867 Y135.94 E.51308
G1 X119.673 Y128.155 E4.21052
G1 X119.673 Y127.845 E.04945
G1 X144.867 Y120.06 E4.21052
G1 X148.08 Y120.06 E.51308
G1 X148.08 Y120.806 E.11922
G2 X141.294 Y122.235 I5.225 J41.659 E1.10854
G1 X129.785 Y125.791 E1.92348
M204 S250
G1 X129.31 Y126.671 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X129.047 Y126.752 E.04395
G1 X129.047 Y129.248 E.39861
G1 X129.31 Y129.329 E.04395
G1 F2250
G1 X129.883 Y129.507 E.0958
G1 F2100
G1 X131.11 Y129.886 E.20499
G1 F1950
G1 X133.563 Y130.644 E.40998
G1 F1800
G1 X134.79 Y131.023 E.20499
G1 F1650
G1 X137.243 Y131.781 E.40998
G1 F1500
G1 X139.696 Y132.539 E.40998
M106 S201.45
M106 S255
G1 F1380
G1 X141.496 Y133.095 E.3008
M106 S201.45
M106 S255
G1 F1650
G1 X142.403 Y133.36 E.15094
G1 F1950
G1 X143.354 Y133.607 E.15685
G1 F2250
G1 X144.057 Y133.77 E.11525
G1 F2400
G1 X144.343 Y133.836 E.04677
G1 F2700
G1 X145.362 Y134.045 E.16613
G1 F3000
G1 X146.409 Y134.234 E.16993
G1 F3215.099
G1 X147.37 Y134.387 E.15537
G1 X148.531 Y134.549 E.18713
G1 X148.78 Y134.578 E.04008
G1 X148.78 Y134.684 E.01688
G1 X148.78 Y136.64 E.31233
G1 X144.761 Y136.64 E.64169
G1 X118.215 Y128.437 E4.43652
G1 X118.215 Y127.563 E.13949
G1 X144.761 Y119.36 E4.43652
G1 X148.78 Y119.36 E.64169
G1 X148.78 Y121.315 E.31218
G1 X148.78 Y121.422 E.01712
G1 X148.388 Y121.47 E.06307
G1 X147.24 Y121.632 E.18519
G1 X146.297 Y121.785 E.15255
G1 F2850
G1 X145.26 Y121.975 E.16827
G1 F2550
G1 X144.251 Y122.185 E.16454
G1 F2400
G1 X143.961 Y122.251 E.04743
G1 F2250
G1 X143.271 Y122.414 E.11319
G1 F1950
G1 X142.366 Y122.65 E.14939
G1 F1650
G1 X141.496 Y122.905 E.14485
G1 F1380
G1 X140.922 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1500
G1 X138.469 Y123.84 E.40998
M106 S201.45
G1 F1650
G1 X136.016 Y124.598 E.40998
G1 F1800
G1 X134.79 Y124.977 E.20499
G1 F1950
G1 X132.336 Y125.735 E.40998
G1 F2100
G1 X131.11 Y126.114 E.20499
G1 F2250
G1 X129.425 Y126.635 E.28163
; WIPE_START
M204 S6000
G1 X129.047 Y126.752 E-.15018
G1 X129.047 Y128.357 E-.60982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z18.16 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z18.16
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z18.16 F4000
            G39.3 S1
            G0 Z18.16 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X127.997 Y130.192 F42000
G1 Z17.76
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444045
M73 P86 R2
G1 F3000
M204 S6000
G1 X142.076 Y134.534 E1.08874
; LINE_WIDTH: 0.481924
G1 X143.055 Y134.813 E.08394
; LINE_WIDTH: 0.524022
G1 X143.564 Y134.95 E.04858
; LINE_WIDTH: 0.562037
G1 X144.068 Y135.086 E.05263
; LINE_WIDTH: 0.60349
G1 X144.517 Y135.201 E.05118
; LINE_WIDTH: 0.64843
G1 X144.961 Y135.315 E.05525
; LINE_WIDTH: 0.655584
G1 X145.111 Y135.33 E.01838
; LINE_WIDTH: 0.615392
G1 X145.389 Y135.355 E.03151
; LINE_WIDTH: 0.566081
G1 X145.66 Y135.38 E.02775
; LINE_WIDTH: 0.517311
G1 X145.932 Y135.404 E.02472
; LINE_WIDTH: 0.468542
G1 X146.204 Y135.428 E.02168
; LINE_WIDTH: 0.424169
G1 X146.456 Y135.448 E.01754
; LINE_WIDTH: 0.384527
G1 X146.705 Y135.468 E.01505
; LINE_WIDTH: 0.345155
G1 X146.953 Y135.488 E.0128
; LINE_WIDTH: 0.305783
G1 X147.202 Y135.507 E.01056
; LINE_WIDTH: 0.269432
G1 X147.467 Y135.526 E.00905
; LINE_WIDTH: 0.236268
G1 X147.73 Y135.544 E.00699
; WIPE_START
G1 X147.467 Y135.526 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.6 Y127.894 Z18.16 F42000
G1 X147.73 Y120.456 Z18.16
G1 Z17.76
G1 E.8 F1800
; LINE_WIDTH: 0.241257
G1 F3000
M204 S6000
G1 X147.4 Y120.479 E.00916
; LINE_WIDTH: 0.284511
G1 X147.067 Y120.503 E.0125
; LINE_WIDTH: 0.325928
G1 X146.823 Y120.522 E.01151
; LINE_WIDTH: 0.365274
G1 X146.578 Y120.542 E.01371
; LINE_WIDTH: 0.404619
G1 X146.334 Y120.562 E.01591
; LINE_WIDTH: 0.44425
G1 X146.086 Y120.582 E.01839
; LINE_WIDTH: 0.488705
G1 X145.817 Y120.606 E.02272
; LINE_WIDTH: 0.537634
G1 X145.548 Y120.631 E.02573
; LINE_WIDTH: 0.586563
G1 X145.279 Y120.655 E.02875
; LINE_WIDTH: 0.635492
G1 X145.01 Y120.68 E.03177
; LINE_WIDTH: 0.664899
G1 X144.961 Y120.685 E.0061
; LINE_WIDTH: 0.645841
G1 X144.471 Y120.811 E.06069
; LINE_WIDTH: 0.597478
G1 X143.977 Y120.938 E.0556
; LINE_WIDTH: 0.561487
G1 X143.675 Y121.019 E.0315
; LINE_WIDTH: 0.524885
G1 X142.97 Y121.211 E.06743
; LINE_WIDTH: 0.47889
G1 X142.038 Y121.477 E.07931
; LINE_WIDTH: 0.444006
G1 X127.997 Y125.808 E1.08568
; WIPE_START
G1 X129.909 Y125.219 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.948 Y128 Z18.16 F42000
G1 Z17.76
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X126.948 Y127.062 E.14975
G1 X123.913 Y128 E.50722
G1 X126.948 Y128.938 E.50722
G1 X126.948 Y128.12 E.13059
M204 S10000
G1 X126.299 Y127.926 F42000
; LINE_WIDTH: 0.803977
G1 F3290.436
M204 S6000
G2 X126.213 Y128.074 I-.032 J.08 E.03846
G1 X126.264 Y128.074 E.00795
; CHANGE_LAYER
; Z_HEIGHT: 18.32
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3290.436
G1 X126.213 Y128.074 E-.12599
G1 X126.17 Y128 E-.21134
G1 X126.213 Y127.926 E-.21135
G1 X126.299 Y127.926 E-.21132
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 33/51
; update layer progress
M73 L33
M991 S0 P32 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z18.32 I1.153 J1.255 P1  F42000
G1 X127.465 Y126.854 Z18.32
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X127.465 Y129.298 E.3902
G1 X123.767 Y128.155 E.61813
G1 X123.767 Y127.845 E.04945
G1 X127.465 Y126.702 E.61813
G1 X127.465 Y126.734 E.00509
; WIPE_START
G1 X127.465 Y128.734 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.474 Y126.42 Z18.72 F42000
G1 Z18.32
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X128.165 Y126.824 E.21864
G1 X128.165 Y129.176 E.37542
G1 X143.018 Y133.765 E2.48219
G2 X148.08 Y134.936 I11.841 J-39.661 E.83026
G1 X148.08 Y135.94 E.1603
G1 X146.59 Y135.94 E.23787
G1 X121.397 Y128.155 E4.21052
G1 X121.397 Y127.845 E.04945
G1 X146.59 Y120.06 E4.21053
G1 X148.08 Y120.06 E.23787
G1 X148.08 Y121.067 E.16087
G2 X143.018 Y122.235 I6.37 J39.184 E.83018
G1 X129.588 Y126.385 E2.24438
M204 S250
G1 X129.128 Y127.259 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X128.865 Y127.341 E.04394
G1 X128.865 Y128.659 E.21057
G1 X129.128 Y128.741 E.04394
G1 F2250
G1 X129.701 Y128.918 E.0958
G1 F2100
G1 X131.14 Y129.362 E.24037
G1 F1950
G1 X134.016 Y130.251 E.48073
G1 F1800
G1 X135.454 Y130.696 E.24037
G1 F1650
G1 X138.331 Y131.584 E.48074
G1 F1500
G1 X141.207 Y132.473 E.48073
M106 S201.45
M106 S255
G1 F1380
G1 X143.219 Y133.095 E.33617
M106 S201.45
M106 S255
G1 F1650
G1 X144.121 Y133.358 E.15014
G1 F1950
G1 X145.067 Y133.604 E.15594
G1 F2250
G1 X146.048 Y133.832 E.16089
G1 F2700
G1 X147.061 Y134.04 E.16515
G1 F3000
G1 X148.102 Y134.229 E.16885
G1 F3215.099
G1 X148.78 Y134.337 E.10966
G1 X148.78 Y134.497 E.02552
G1 X148.78 Y136.64 E.34222
G1 X146.485 Y136.64 E.36649
G1 X118.525 Y128 E4.67275
G1 X146.485 Y119.36 E4.67275
G1 X148.78 Y119.36 E.36649
G1 X148.78 Y121.504 E.34233
G1 X148.78 Y121.664 E.02556
G1 X147.977 Y121.793 E.1299
G1 F2850
G1 X146.814 Y122.009 E.18887
G1 F2550
G1 X145.946 Y122.191 E.14166
G1 F2400
G1 X145.756 Y122.234 E.03112
G1 F2250
G1 X144.973 Y122.419 E.12839
G1 F1950
G1 X144.079 Y122.653 E.14753
G1 F1650
G1 X143.219 Y122.905 E.1431
G1 F1380
G1 X142.646 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1500
G1 X139.769 Y123.971 E.48074
M106 S201.45
G1 F1650
G1 X136.893 Y124.86 E.48074
G1 F1800
G1 X135.454 Y125.304 E.24037
G1 F1950
G1 X132.578 Y126.193 E.48074
G1 F2100
G1 X131.14 Y126.638 E.24037
G1 F2250
G1 X129.243 Y127.224 E.31702
; WIPE_START
M204 S6000
G1 X128.865 Y127.341 E-.15018
G1 X128.865 Y128.659 E-.50112
G1 X129.128 Y128.741 E-.10458
G1 X129.138 Y128.744 E-.00412
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z18.72 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z18.72
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z18.72 F4000
            G39.3 S1
            G0 Z18.72 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X127.815 Y129.603 F42000
G1 Z18.32
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.443971
G1 F3000
M204 S6000
G1 X143.795 Y134.533 E1.23544
; LINE_WIDTH: 0.481501
G1 X144.767 Y134.81 E.08337
; LINE_WIDTH: 0.523107
G1 X145.272 Y134.946 E.04809
; LINE_WIDTH: 0.560611
G1 X145.772 Y135.081 E.05204
; LINE_WIDTH: 0.602158
G1 X146.231 Y135.199 E.05211
; LINE_WIDTH: 0.647795
G1 X146.685 Y135.315 E.05636
; LINE_WIDTH: 0.657882
G1 X146.809 Y135.328 E.01525
; LINE_WIDTH: 0.623011
G1 X147.12 Y135.356 E.03586
; LINE_WIDTH: 0.579435
G1 X147.425 Y135.383 E.03211
; LINE_WIDTH: 0.53629
G1 X147.73 Y135.411 E.0291
; WIPE_START
G1 X147.425 Y135.383 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.582 Y127.752 Z18.72 F42000
G1 X147.73 Y120.589 Z18.72
G1 Z18.32
G1 E.8 F1800
; LINE_WIDTH: 0.534126
G1 F3000
M204 S6000
G1 X147.469 Y120.613 E.02479
; LINE_WIDTH: 0.573283
G1 X147.208 Y120.637 E.02713
; LINE_WIDTH: 0.612441
G1 X146.946 Y120.661 E.02948
; LINE_WIDTH: 0.655602
G2 X146.555 Y120.717 I.036 J1.638 E.04843
; LINE_WIDTH: 0.634577
G1 X146.115 Y120.831 E.05334
; LINE_WIDTH: 0.591946
G1 X145.67 Y120.946 E.0495
; LINE_WIDTH: 0.552675
G1 X145.173 Y121.081 E.05079
; LINE_WIDTH: 0.516708
G1 X144.671 Y121.217 E.04702
; LINE_WIDTH: 0.478028
G1 X143.751 Y121.48 E.07813
; LINE_WIDTH: 0.443917
G1 X127.815 Y126.397 E1.23187
; WIPE_START
G1 X129.727 Y125.807 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.812 Y128 Z18.72 F42000
G1 Z18.32
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.727557
G1 F3704.436
M204 S6000
G1 X126.812 Y127.588 E.05705
G1 X125.48 Y128 E.19325
G1 X126.812 Y128.412 E.19325
G1 X126.812 Y128.12 E.04042
; CHANGE_LAYER
; Z_HEIGHT: 18.88
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3704.436
G1 X126.812 Y128.412 E-.11085
G1 X125.48 Y128 E-.5299
G1 X125.779 Y127.907 E-.11926
; WIPE_END
M73 P87 R2
G1 E-.04 F1800
; layer num/total_layer_count: 34/51
; update layer progress
M73 L34
M991 S0 P33 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z18.88 I-.174 J1.695 P1  F42000
M106 S255
G1 X128.151 Y128.151 Z18.88
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X128.151 Y128.977 E.13191
G1 X125.49 Y128.155 E.44463
G1 X125.49 Y127.845 E.04945
G1 X128.151 Y127.023 E.44463
G1 X128.151 Y128.031 E.16093
M204 S10000
G1 X128.851 Y127.906 F42000
G1 F3215.099
M204 S6000
G1 X128.851 Y128.855 E.15147
G1 X144.741 Y133.765 E2.65572
G2 X148.08 Y134.61 I10.817 J-35.754 E.55011
G1 X148.08 Y135.868 E.20093
G1 X123.12 Y128.155 E4.17146
G1 X123.12 Y127.845 E.04945
G1 X148.08 Y120.132 E4.17146
G1 X148.08 Y121.39 E.2009
G2 X144.741 Y122.235 I7.62 J37.149 E.55016
G1 X128.851 Y127.145 E2.65568
G1 X128.851 Y127.786 E.10234
M204 S250
G1 X129.55 Y127.661 F42000
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X129.55 Y128.339 E.10812
M106 S201.45
M106 S255
G1 F1140
G1 X130.124 Y128.516 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X139.621 Y131.45 E1.58717
M106 S201.45
M106 S255
G1 F1380
G1 X144.942 Y133.095 E.88939
M106 S201.45
M106 S255
G1 F1650
G1 X145.84 Y133.357 E.14927
G1 F1950
G1 X146.779 Y133.602 E.155
G1 F2250
G1 X147.754 Y133.828 E.15988
G1 F2550
G1 X148.761 Y134.035 E.16411
G1 F2850
G1 X148.78 Y134.039 E.00308
G1 F3215.099
G1 X148.78 Y134.255 E.0345
G1 X148.78 Y136.64 E.38084
G1 X148.208 Y136.64 E.09129
G1 X120.249 Y128 E4.67275
G1 X148.208 Y119.36 E4.67275
G1 X148.78 Y119.36 E.0913
G1 X148.78 Y121.746 E.38098
G1 X148.78 Y121.963 E.03461
G1 F2850
G1 X148.605 Y121.995 E.02839
G1 F2550
G1 X147.639 Y122.198 E.1576
G1 F2250
G1 X146.675 Y122.424 E.15823
G1 F1950
G1 X145.792 Y122.656 E.14568
G1 F1650
G1 X144.943 Y122.905 E.14135
G1 F1380
G1 X144.369 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X134.872 Y126.017 E1.58719
M106 S201.45
M106 S255
G1 F1140
G1 X129.665 Y127.626 E.87024
M106 S201.45
; WIPE_START
M204 S6000
G1 X129.55 Y128.339 E-.27426
G1 X130.124 Y128.516 E-.228
G1 X130.772 Y128.716 E-.25774
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.28 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z19.28
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z19.28 F4000
            G39.3 S1
            G0 Z19.28 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X128.501 Y129.282 F42000
G1 Z18.88
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.443937
G1 F3000
M204 S6000
G1 X145.513 Y134.531 E1.31515
; LINE_WIDTH: 0.481074
G1 X146.48 Y134.806 E.08278
; LINE_WIDTH: 0.522189
G1 X146.981 Y134.942 E.04767
; LINE_WIDTH: 0.559253
G1 X147.478 Y135.076 E.05155
; LINE_WIDTH: 0.578981
G1 X147.73 Y135.141 E.02726
; WIPE_START
G1 X147.478 Y135.076 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.613 Y127.445 Z19.28 F42000
G1 X147.73 Y120.859 Z19.28
G1 Z18.88
G1 E.8 F1800
; LINE_WIDTH: 0.574469
G1 F3000
M204 S6000
G1 X147.36 Y120.955 E.03962
; LINE_WIDTH: 0.550154
G1 X146.869 Y121.088 E.04995
; LINE_WIDTH: 0.514982
G1 X146.373 Y121.223 E.0463
; LINE_WIDTH: 0.477207
G1 X145.464 Y121.483 E.07701
; LINE_WIDTH: 0.443891
G1 X128.501 Y126.718 E1.3112
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 19.44
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3000
G1 X130.412 Y126.128 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 35/51
; update layer progress
M73 L35
M991 S0 P34 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z19.44 I-1.461 J-.877 P1  F42000
G1 X129.874 Y127.023 Z19.44
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X129.874 Y127.246 E.03562
G1 X129.874 Y127.646 E.06387
G1 F2550
G1 X129.874 Y128.354 E.11301
G1 F3215.099
G1 X129.874 Y128.754 E.06387
G1 X129.874 Y128.977 E.03563
G1 X127.214 Y128.155 E.44463
G1 X127.214 Y127.845 E.04945
G1 X129.76 Y127.058 E.42547
; WIPE_START
G1 X129.874 Y127.246 E-.08357
G1 X129.874 Y127.646 E-.152
G1 X129.874 Y128.354 E-.26895
G1 X129.874 Y128.754 E-.152
G1 X129.874 Y128.977 E-.08479
G1 X129.827 Y128.962 E-.0187
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.301 Y126.921 Z19.84 F42000
G1 Z19.44
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X130.956 Y127.027 E.05763
G1 X130.574 Y127.145 E.06387
G1 F1617.193
G1 X130.574 Y127.43 E.04545
G1 F420
G1 X130.574 Y128.57 E.18207
M106 S201.45
M106 S255
G1 F1617.305
G1 X130.574 Y128.855 E.04545
G1 F3215.099
G1 X130.956 Y128.973 E.06387
G1 X146.465 Y133.765 E2.59185
G2 X148.08 Y134.215 I8.533 J-27.535 E.26777
G1 X148.08 Y135.335 E.17892
M73 P88 R2
G1 X124.844 Y128.155 E3.88342
G1 X124.844 Y127.845 E.04945
G1 X148.08 Y120.665 E3.88342
G1 X148.08 Y121.784 E.17874
G2 X146.464 Y122.235 I7.402 J29.649 E.2679
G1 X131.416 Y126.885 E2.51499
M204 S250
G1 X131.274 Y127.661 F42000
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X131.274 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X131.274 Y128.023 E.00746
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X131.274 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X131.847 Y128.516 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X141.344 Y131.45 E1.58721
M106 S201.45
M106 S255
M73 P88 R1
G1 F1380
G1 X146.666 Y133.095 E.88941
M106 S201.45
M106 S255
G1 F1650
G1 X147.558 Y133.355 E.14834
G1 F1950
G1 X148.492 Y133.599 E.15406
G1 F2250
G1 X148.78 Y133.666 E.04728
G1 F3215.099
G1 X148.78 Y133.957 E.04641
G1 X148.78 Y136.284 E.37165
G1 X121.972 Y128 E4.48027
G1 X148.78 Y119.716 E4.48027
G1 X148.78 Y122.045 E.37192
G1 X148.78 Y122.335 E.04621
G1 F2100
G1 X148.376 Y122.43 E.06629
G1 F1950
G1 X147.505 Y122.659 E.14382
G1 F1650
G1 X146.666 Y122.905 E.13959
G1 F1380
G1 X146.093 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X136.596 Y126.017 E1.58719
M106 S201.45
M106 S255
G1 F1140
G1 X131.389 Y127.626 E.87024
M106 S201.45
; WIPE_START
M204 S6000
G1 X131.274 Y127.977 E-.14018
G1 X131.274 Y128.023 E-.01776
G1 X131.274 Y128.339 E-.11978
G1 X131.847 Y128.516 E-.228
G1 X132.487 Y128.713 E-.25428
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.84 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z19.84
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z19.84 F4000
            G39.3 S1
            G0 Z19.84 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X130.224 Y129.282 F42000
G1 Z19.44
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444559
G1 F3000
M204 S6000
G1 X146.317 Y134.255 E1.24659
G1 X147.73 Y134.672 E.10909
; WIPE_START
G1 X146.317 Y134.255 E-.56011
G1 X145.814 Y134.1 E-.19989
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.84 I1.203 J.181 P1  F42000
G1 X147.73 Y121.328 Z19.84
G1 Z19.44
G1 E.8 F1800
; LINE_WIDTH: 0.444542
G1 F3000
M204 S6000
G1 X146.316 Y121.745 E.10912
G1 X130.224 Y126.718 E1.24649
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 20
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X132.135 Y126.127 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 36/51
; update layer progress
M73 L36
M991 S0 P35 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z20 I-1.461 J-.877 P1  F42000
G1 X131.598 Y127.023 Z20
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X131.598 Y127.246 E.03563
G1 X131.598 Y127.646 E.06387
G1 F2550
G1 X131.598 Y128.354 E.11301
G1 F3215.099
G1 X131.598 Y128.754 E.06387
G1 X131.598 Y128.977 E.03563
G1 X128.937 Y128.155 E.44463
G1 X128.937 Y127.845 E.04945
G1 X131.483 Y127.058 E.42547
; WIPE_START
G1 X131.598 Y127.246 E-.08358
G1 X131.598 Y127.646 E-.152
G1 X131.598 Y128.354 E-.26895
G1 X131.598 Y128.754 E-.152
G1 X131.598 Y128.977 E-.08478
G1 X131.551 Y128.962 E-.0187
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.025 Y126.921 Z20.4 F42000
G1 Z20
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X132.68 Y127.027 E.05763
G1 X132.298 Y127.145 E.06387
G1 F1617.249
G1 X132.298 Y127.43 E.04545
G1 F420
G1 X132.298 Y128.57 E.18207
M106 S201.45
M106 S255
G1 F1617.249
G1 X132.298 Y128.855 E.04545
G1 F3215.099
G1 X132.68 Y128.973 E.06387
G1 X148.08 Y133.732 E2.57378
G1 X148.08 Y134.803 E.171
G1 X126.567 Y128.155 E3.59538
G1 X126.567 Y127.845 E.04945
G1 X148.08 Y121.197 E3.59538
G1 X148.08 Y122.268 E.171
G1 X133.139 Y126.885 E2.49699
M204 S250
G1 X132.997 Y127.661 F42000
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X132.997 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X132.997 Y128.023 E.00746
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X132.997 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X133.571 Y128.516 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X143.068 Y131.45 E1.58721
M106 S201.45
M106 S255
G1 F1380
G1 X148.39 Y133.095 E.88941
M106 S201.45
M106 S255
G1 F1500
G1 X148.78 Y133.209 E.06493
M106 S201.45
M106 S255
G1 F3215.099
G1 X148.78 Y133.583 E.05967
G1 X148.78 Y135.752 E.3463
G1 X123.696 Y128 E4.19222
G1 X148.78 Y120.248 E4.19222
G1 X148.78 Y122.418 E.34638
G1 X148.78 Y122.791 E.05952
G1 F1500
G1 X148.389 Y122.905 E.06498
M106 S201.45
M106 S255
G1 F1380
M73 P89 R1
G1 X147.816 Y123.082 E.0958
M106 S201.45
M106 S255
G1 F1260
G1 X138.319 Y126.017 E1.58718
M106 S201.45
M106 S255
G1 F1140
G1 X133.112 Y127.626 E.87023
M106 S201.45
; WIPE_START
M204 S6000
G1 X132.997 Y127.977 E-.14018
G1 X132.997 Y128.023 E-.01776
G1 X132.997 Y128.339 E-.11978
G1 X133.571 Y128.516 E-.228
G1 X134.21 Y128.713 E-.25428
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z20.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z20.4 F4000
            G39.3 S1
            G0 Z20.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X131.948 Y129.282 F42000
G1 Z20
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.443536
G1 F3000
M204 S6000
G1 X147.73 Y134.159 E1.21874
; WIPE_START
G1 X145.819 Y133.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.4 I1.201 J.196 P1  F42000
G1 X147.73 Y121.841 Z20.4
G1 Z20
G1 E.8 F1800
; LINE_WIDTH: 0.443547
G1 F3000
M204 S6000
G1 X131.948 Y126.718 E1.21878
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 20.56
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X133.859 Y126.127 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 37/51
; update layer progress
M73 L37
M991 S0 P36 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z20.56 I-1.461 J-.877 P1  F42000
G1 X133.321 Y127.023 Z20.56
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X133.321 Y127.246 E.03563
G1 X133.321 Y127.646 E.06387
G1 F2550
G1 X133.321 Y128.354 E.11301
G1 F3215.099
G1 X133.321 Y128.754 E.06387
G1 X133.321 Y128.977 E.03562
G1 X130.661 Y128.155 E.44463
G1 X130.661 Y127.845 E.04945
G1 X133.207 Y127.058 E.42547
; WIPE_START
G1 X133.321 Y127.246 E-.08357
G1 X133.321 Y127.646 E-.152
G1 X133.321 Y128.354 E-.26895
G1 X133.321 Y128.754 E-.152
G1 X133.321 Y128.977 E-.08478
G1 X133.274 Y128.962 E-.0187
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.654 Y125.879 Z20.96 F42000
G1 Z20.56
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y121.73 E2.24382
G1 X148.08 Y122.801 E.171
G1 X134.403 Y127.027 E2.28574
G1 X134.021 Y127.145 E.06387
G1 F1617.249
G1 X134.021 Y127.43 E.04545
G1 F420
G1 X134.021 Y128.57 E.18207
M106 S201.45
M106 S255
G1 F1617.193
G1 X134.021 Y128.855 E.04545
G1 F3215.099
G1 X134.403 Y128.973 E.06387
G1 X148.08 Y133.199 E2.28574
G1 X148.08 Y134.27 E.171
G1 X128.291 Y128.155 E3.30734
G1 X128.291 Y127.845 E.04945
G1 X134.54 Y125.914 E1.04436
; WIPE_START
G1 X136.45 Y125.324 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.721 Y127.661 Z20.96 F42000
G1 Z20.56
G1 E.8 F1800
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X134.721 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X134.721 Y128.023 E.00747
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X134.721 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X135.103 Y128.457 E.06387
M106 S201.45
M106 S255
G1 X148.78 Y132.683 E2.28574
M106 S201.45
M106 S255
G1 F2850
G1 X148.78 Y133.125 E.07051
G1 F3215.099
G1 X148.78 Y135.219 E.3344
G1 X125.419 Y128 E3.90418
G1 X148.78 Y120.781 E3.90419
G1 X148.78 Y122.875 E.33434
G1 F2850
G1 X148.78 Y123.317 E.07057
G1 F1140
G1 X134.836 Y127.626 E2.33045
M106 S201.45
; WIPE_START
M204 S6000
G1 X134.721 Y127.977 E-.14017
G1 X134.721 Y128.023 E-.01777
G1 X134.721 Y128.339 E-.11977
G1 X135.103 Y128.457 E-.152
G1 X135.934 Y128.713 E-.33029
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.96 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z20.96
M73 P90 R1
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z20.96 F4000
            G39.3 S1
            G0 Z20.96 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X133.671 Y129.282 F42000
G1 Z20.56
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.443526
G1 F3000
M204 S6000
G1 X147.73 Y133.627 E1.08561
; WIPE_START
G1 X145.819 Y133.036 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.96 I1.198 J.215 P1  F42000
G1 X147.73 Y122.373 Z20.96
G1 Z20.56
G1 E.8 F1800
; LINE_WIDTH: 0.443547
G1 F3000
M204 S6000
G1 X133.671 Y126.718 E1.08568
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 21.12
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3000
G1 X135.582 Y126.127 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 38/51
; update layer progress
M73 L38
M991 S0 P37 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z21.12 I-1.461 J-.877 P1  F42000
G1 X135.045 Y127.023 Z21.12
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X135.045 Y127.246 E.03563
G1 X135.045 Y127.646 E.06387
G1 F2550
G1 X135.045 Y128.354 E.11301
G1 F3215.099
G1 X135.045 Y128.754 E.06387
G1 X135.045 Y128.977 E.03563
G1 X132.384 Y128.155 E.44463
G1 X132.384 Y127.845 E.04945
G1 X134.93 Y127.058 E.42547
; WIPE_START
G1 X135.045 Y127.246 E-.08358
G1 X135.045 Y127.646 E-.152
G1 X135.045 Y128.354 E-.26894
G1 X135.045 Y128.754 E-.152
G1 X135.045 Y128.977 E-.08479
G1 X134.998 Y128.962 E-.0187
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.32 Y125.896 Z21.52 F42000
G1 Z21.12
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X148.08 Y122.262 E1.96536
G1 X148.08 Y123.333 E.171
G1 X142.345 Y125.105 E.95841
G2 X140.184 Y125.773 I-.287 J2.901 E.37091
G1 X136.127 Y127.027 E.67812
G1 X135.745 Y127.145 E.06387
G1 F1617.36
G1 X135.745 Y127.43 E.04545
G1 F420
G1 X135.745 Y128.57 E.18207
M106 S201.45
M106 S255
G1 F1617.305
G1 X135.745 Y128.855 E.04545
G1 F3215.099
G1 X136.127 Y128.973 E.06387
G1 X140.18 Y130.225 E.67736
G2 X142.344 Y130.894 I1.897 J-2.303 E.37098
G1 X148.08 Y132.667 E.95867
G1 X148.08 Y133.738 E.171
G1 X130.014 Y128.155 E3.0193
G1 X130.014 Y127.845 E.04945
G1 X136.206 Y125.932 E1.03478
; WIPE_START
G1 X138.117 Y125.341 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.444 Y127.661 Z21.52 F42000
G1 Z21.12
G1 E.8 F1800
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X136.444 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X136.444 Y128.023 E.00746
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X136.444 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X136.827 Y128.457 E.06387
M106 S201.45
M106 S255
G1 X140.535 Y129.603 E.61979
M106 S201.45
M106 S255
G1 F1380
G1 X140.646 Y129.701 E.02367
M106 S201.45
M106 S255
G1 F1800
G1 X140.764 Y129.793 E.02391
G1 F2100
G1 X140.89 Y129.877 E.02414
G1 F2550
G1 X141.022 Y129.953 E.02435
G1 F2700
G1 X141.158 Y130.019 E.02411
G1 F2850
G1 X141.368 Y130.1 E.03592
G1 F3000
G1 X141.512 Y130.142 E.02404
G1 F2850
G1 X141.661 Y130.175 E.02435
G1 F2700
G1 X141.816 Y130.197 E.02492
G1 F2550
G1 X141.916 Y130.206 E.01608
G1 F2250
G1 X142.093 Y130.21 E.0282
G1 F1950
G1 X142.197 Y130.206 E.0166
G1 F1500
G1 X142.376 Y130.187 E.02873
M106 S201.45
M106 S255
G1 F1140
G1 X142.408 Y130.181 E.00521
G1 X148.78 Y132.15 E1.06496
M106 S201.45
M106 S255
G1 F2850
G1 X148.78 Y132.598 E.0715
G1 F3215.099
G1 X148.78 Y134.686 E.33341
M73 P91 R1
G1 X127.143 Y128 E3.61615
G1 X148.78 Y121.314 E3.61615
G1 X148.78 Y123.402 E.33341
G1 F2850
G1 X148.78 Y123.85 E.0715
G1 F1140
G1 X142.408 Y125.819 E1.06496
G1 X142.374 Y125.813 E.00551
M106 S201.45
M106 S255
G1 F1500
G1 X142.223 Y125.796 E.02422
M106 S201.45
M106 S255
G1 F1950
G1 X142.071 Y125.79 E.02428
G1 F2250
G1 X141.919 Y125.794 E.02427
G1 F2550
G1 X141.699 Y125.819 E.03533
G1 F2850
G2 X141.121 Y125.998 I.573 J2.874 E.0969
G1 F2700
G1 X140.969 Y126.076 E.02726
G1 F2400
G1 X140.886 Y126.126 E.01543
G1 F2250
G1 X140.8 Y126.182 E.01639
G1 F1800
G1 X140.66 Y126.287 E.02799
G1 F1500
G1 X140.583 Y126.353 E.01615
M106 S201.45
M106 S255
G1 F1260
G1 X140.539 Y126.396 E.00988
M106 S201.45
M106 S255
G1 F1140
G1 X136.559 Y127.626 E.66507
M106 S201.45
; WIPE_START
M204 S6000
G1 X136.444 Y127.977 E-.14018
G1 X136.444 Y128.023 E-.01776
G1 X136.444 Y128.339 E-.11978
G1 X136.827 Y128.457 E-.152
G1 X137.657 Y128.713 E-.33028
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z21.52 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z21.52
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z21.52 F4000
            G39.3 S1
            G0 Z21.52 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X135.395 Y129.282 F42000
G1 Z21.12
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.443337
G1 F3000
M204 S6000
G1 X139.94 Y130.687 E.35078
G1 X140.004 Y130.72 E.00527
; LINE_WIDTH: 0.405277
G1 X140.067 Y130.753 E.00465
; LINE_WIDTH: 0.374534
G1 X140.177 Y130.805 E.00708
; LINE_WIDTH: 0.340509
G1 X140.279 Y130.854 E.00567
; LINE_WIDTH: 0.32328
G1 X140.285 Y130.857 E.00033
; LINE_WIDTH: 0.297388
G1 X140.492 Y130.947 E.00912
; LINE_WIDTH: 0.253939
G1 X140.713 Y131.034 E.00725
; LINE_WIDTH: 0.226973
G1 X140.993 Y131.131 E.00722
M204 S10000
G1 X141.207 Y131.198 F42000
; LINE_WIDTH: 0.227695
G1 F3000
M204 S6000
G1 X141.462 Y131.265 E.00647
; LINE_WIDTH: 0.254412
G1 X141.684 Y131.315 E.00698
; LINE_WIDTH: 0.28993
G1 X141.85 Y131.348 E.00654
; LINE_WIDTH: 0.325399
G1 X141.977 Y131.369 E.00604
; LINE_WIDTH: 0.360034
G1 X142.098 Y131.388 E.00673
; LINE_WIDTH: 0.39419
G1 X142.198 Y131.401 E.0063
; LINE_WIDTH: 0.427646
G1 X142.289 Y131.412 E.00639
; LINE_WIDTH: 0.443517
G1 X147.73 Y133.094 E.4202
; WIPE_START
G1 X145.819 Y132.504 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z21.52 I1.194 J.238 P1  F42000
G1 X147.73 Y122.906 Z21.52
G1 Z21.12
G1 E.8 F1800
; LINE_WIDTH: 0.443529
G1 F3000
M204 S6000
G1 X142.29 Y124.587 E.42006
; LINE_WIDTH: 0.425719
G1 X142.187 Y124.6 E.00727
; LINE_WIDTH: 0.38856
G1 X142.075 Y124.615 E.00694
; LINE_WIDTH: 0.353577
G1 X141.959 Y124.634 E.00625
; LINE_WIDTH: 0.320646
G1 X141.836 Y124.655 E.00573
; LINE_WIDTH: 0.289333
G1 X141.682 Y124.687 E.00604
; LINE_WIDTH: 0.259582
G1 X141.524 Y124.72 E.00515
; LINE_WIDTH: 0.228525
G1 X141.187 Y124.809 E.00863
M204 S10000
G1 X140.979 Y124.874 F42000
; LINE_WIDTH: 0.228572
G1 F3000
M204 S6000
G1 X140.645 Y124.992 E.00878
; LINE_WIDTH: 0.267222
G1 X140.415 Y125.086 E.00831
; LINE_WIDTH: 0.307915
G1 X140.272 Y125.15 E.00673
; LINE_WIDTH: 0.350283
G1 X140.12 Y125.222 E.00885
; LINE_WIDTH: 0.391512
G1 X140.03 Y125.267 E.00626
; LINE_WIDTH: 0.443173
G1 X139.94 Y125.313 E.00745
G1 X135.395 Y126.718 E.35055
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 21.68
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X137.306 Y126.127 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 39/51
; update layer progress
M73 L39
M991 S0 P38 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z21.68 I-1.485 J-.835 P1  F42000
G1 X135.86 Y128.696 Z21.68
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X134.108 Y128.155 E.29287
G1 X134.108 Y127.845 E.04945
G1 X136.768 Y127.023 E.44463
G1 X136.768 Y127.246 E.03562
G1 X136.768 Y127.646 E.06387
G1 F2550
G1 X136.768 Y128.354 E.11301
G1 F3215.099
G1 X136.768 Y128.754 E.06387
G1 X136.768 Y128.977 E.03563
G1 X135.975 Y128.732 E.1326
; WIPE_START
G1 X134.108 Y128.155 E-.74258
G1 X134.108 Y128.109 E-.01742
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.468 Y128.001 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
G1 F420
M204 S6000
G1 X137.468 Y128.57 E.09088
M106 S201.45
M106 S255
G1 F1617.249
G1 X137.468 Y128.855 E.04545
G1 F3215.099
G1 X137.85 Y128.973 E.06387
G1 X139.567 Y129.503 E.2869
G2 X140.575 Y130.517 I2.779 J-1.755 E.2301
G1 X140.416 Y130.837 E.05698
G1 X131.738 Y128.155 E1.45038
G1 X131.738 Y127.845 E.04945
G1 X140.417 Y125.163 E1.45052
G1 X140.575 Y125.484 E.05715
G2 X139.564 Y126.497 I1.668 J2.675 E.23056
G1 X137.85 Y127.027 E.28646
G1 X137.468 Y127.145 E.06387
G1 F1617.193
G1 X137.468 Y127.43 E.04545
G1 F420
G1 X137.468 Y127.881 E.07203
M106 S201.45
M106 S255
; WIPE_START
G1 X137.468 Y128.57 E-.26187
G1 X137.468 Y128.855 E-.10817
G1 X137.85 Y128.973 E-.152
G1 X138.449 Y129.158 E-.23796
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.855 Y125.094 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X141.8 Y124.736 E.05787
G1 X148.08 Y122.795 E1.04963
G1 X148.08 Y123.866 E.171
G1 X143.269 Y125.353 E.804
G2 X141.975 Y125.089 I-1.234 J2.751 E.21266
; WIPE_START
G1 X141.8 Y124.736 E-.14989
G1 X143.334 Y124.262 E-.61011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.809 Y131.267 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X141.859 Y130.913 E.05712
G2 X143.266 Y130.646 I.152 J-3.045 E.23077
G1 X148.08 Y132.134 E.80464
G1 X148.08 Y133.205 E.171
G1 X141.923 Y131.302 E1.02894
; WIPE_START
G1 X141.859 Y130.913 E-.15009
G1 X142.228 Y130.906 E-.14019
G1 X142.49 Y130.878 E-.10031
G1 X142.874 Y130.793 E-.1492
G1 X143.266 Y130.646 E-.15911
G1 X143.419 Y130.694 E-.0611
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.08 I.609 J-1.054 P1  F42000
G1 X138.168 Y127.661 Z22.08
G1 Z21.68
G1 E.8 F1800
; FEATURE: Outer wall
G1 F300
M204 S5000
G1 X138.168 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X138.168 Y128.023 E.00747
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X138.168 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X138.55 Y128.457 E.06387
M106 S201.45
M106 S255
G1 X140.048 Y128.919 E.25029
G1 X140.057 Y128.939 E.00348
M106 S201.45
M106 S255
G1 F1500
G1 X140.109 Y129.044 E.01865
M106 S201.45
M106 S255
G1 F2400
G1 X140.196 Y129.192 E.02746
G1 F3215.099
G1 X140.332 Y129.382 E.03724
G1 X140.418 Y129.482 E.02103
G2 X142.575 Y130.148 I1.649 J-1.512 E.37791
G1 X142.677 Y130.121 E.01685
G1 X142.794 Y130.084 E.01966
G1 X142.9 Y130.043 E.01811
G1 F2550
G1 X143.014 Y129.992 E.01997
G1 F1800
G1 X143.141 Y129.926 E.02287
G1 F1260
G1 X143.197 Y129.892 E.01033
M106 S201.45
M106 S255
G1 F1140
G1 X148.78 Y131.618 E.93313
M106 S201.45
M106 S255
G1 F2850
G1 X148.78 Y132.066 E.0715
G1 F3215.099
G1 X148.78 Y134.154 E.33341
G1 X128.866 Y128 E3.32811
G1 X148.78 Y121.846 E3.32811
G1 X148.78 Y123.934 E.33341
G1 F2850
G1 X148.78 Y124.382 E.0715
G1 F1140
G1 X143.197 Y126.107 E.93306
M106 S201.45
M106 S255
G1 F1260
G1 X143.142 Y126.074 E.01027
M106 S201.45
M106 S255
G1 F2100
G1 X142.955 Y125.98 E.03336
G1 F3000
G1 X142.815 Y125.924 E.02412
G1 F3215.099
G1 X142.675 Y125.878 E.02352
G1 X142.574 Y125.852 E.01671
G2 X140.42 Y126.518 I-.503 J2.189 E.37699
G1 X140.374 Y126.567 E.01085
G1 X140.301 Y126.658 E.01865
G1 X140.23 Y126.756 E.01921
G1 F2850
G1 X140.169 Y126.851 E.01815
G1 F2250
G1 X140.104 Y126.966 E.02106
G1 F1500
G1 X140.048 Y127.081 E.02039
M106 S201.45
M106 S255
G1 F1140
G1 X138.283 Y127.626 E.29496
M106 S201.45
; WIPE_START
M204 S6000
G1 X138.168 Y127.977 E-.14017
G1 X138.168 Y128.023 E-.01777
G1 X138.168 Y128.339 E-.11977
G1 X138.55 Y128.457 E-.152
G1 X139.381 Y128.713 E-.33029
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.08 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z22.08
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z22.08 F4000
            G39.3 S1
            G0 Z22.08 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X138.773 Y129.624 F42000
G1 Z21.68
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.286055
G1 F3000
M204 S6000
G1 X139.581 Y130.179 E.03709
M204 S10000
G1 X139.496 Y130.017 F42000
; LINE_WIDTH: 0.443545
G1 F3000
M204 S6000
G1 X137.118 Y129.282 E.18358
; WIPE_START
G1 X139.029 Y129.873 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.118 Y126.718 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
; LINE_WIDTH: 0.44354
M73 P92 R1
G1 F3000
M204 S6000
G1 X139.497 Y125.983 E.18368
M204 S10000
G1 X139.578 Y125.822 F42000
; LINE_WIDTH: 0.329232
G1 F3000
M204 S6000
G1 X138.798 Y126.368 E.0454
; WIPE_START
G1 X139.578 Y125.822 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.88 Y124.798 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
; LINE_WIDTH: 0.252209
G1 F3000
M204 S6000
G2 X142.873 Y124.808 I-.185 J30.686 E.03036
M204 S10000
G1 X142.872 Y124.798 F42000
; LINE_WIDTH: 0.440013
G1 F3000
M204 S6000
G3 X143.292 Y124.81 I-.145 J12.695 E.03065
G1 X147.73 Y123.439 E.33898
; WIPE_START
G1 X145.819 Y124.029 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.08 I-1.175 J-.318 P1  F42000
G1 X143.877 Y131.201 Z22.08
G1 Z21.68
G1 E.8 F1800
; LINE_WIDTH: 0.254328
G1 F3000
M204 S6000
G3 X142.873 Y131.192 I-.17 J-36.095 E.03074
M204 S10000
G1 X142.873 Y131.2 F42000
; LINE_WIDTH: 0.373679
G1 F3000
M204 S6000
G1 X143.811 Y131.181 E.0543
M204 S10000
G1 X143.032 Y131.11 F42000
; LINE_WIDTH: 0.443528
G1 F3000
M204 S6000
G1 X147.73 Y132.561 E.36276
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 22.24
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X145.819 Y131.971 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 40/51
; update layer progress
M73 L40
M991 S0 P39 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z22.24 I.782 J-1.514 P1  F42000
G1 X138.453 Y128.165 Z22.24
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F2758
M204 S6000
G1 X138.458 Y128.301 E.02182
G1 X138.464 Y128.345 E.0071
G2 X138.58 Y129.004 I4.384 J-.435 E.10698
G1 X135.831 Y128.155 E.45943
G1 X135.831 Y127.845 E.04945
G1 X138.577 Y126.997 E.45884
G1 X138.491 Y127.435 E.07134
G1 X138.465 Y127.655 E.03529
G1 X138.457 Y127.717 E.00997
G1 X138.446 Y128.001 E.04546
G1 X138.448 Y128.045 E.00698
M204 S10000
G1 X139.193 Y127.49 F42000
G1 F2758
M204 S6000
G1 X139.182 Y127.544 E.00876
G1 F2463.697
G1 X139.155 Y127.772 E.03658
G1 F1140
G1 X139.146 Y128.001 E.03659
M106 S201.45
M106 S255
G1 F1260
G1 X139.156 Y128.241 E.03841
M106 S201.45
M106 S255
G1 F2758
G1 X139.192 Y128.512 E.04359
G1 X139.205 Y128.574 E.01021
G2 X139.772 Y129.81 I3.256 J-.746 E.21858
G1 X139.595 Y130.05 E.04769
G1 X133.461 Y128.155 E1.02515
G1 X133.461 Y127.845 E.04945
G1 X139.595 Y125.95 E1.02518
G1 X139.772 Y126.189 E.04757
G2 X139.217 Y127.373 I2.371 J1.835 E.21045
; WIPE_START
G1 F3215.099
G1 X139.182 Y127.544 E-.06645
G1 X139.155 Y127.772 E-.08705
G1 X139.146 Y128.001 E-.08709
G1 X139.156 Y128.241 E-.09142
G1 X139.192 Y128.512 E-.10375
G1 X139.205 Y128.574 E-.0243
G1 X139.302 Y128.937 E-.14281
G1 X139.374 Y129.128 E-.07727
G1 X139.471 Y129.314 E-.07987
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.514 Y125.047 Z22.64 F42000
G1 Z22.24
G1 E.8 F1800
G1 F2758
M204 S6000
G1 X148.08 Y123.328 E.93017
G1 X148.08 Y124.398 E.171
G1 X143.848 Y125.706 E.70735
G2 X143.244 Y125.342 I-2 J2.634 E.11275
G1 X142.626 Y125.092 E.10652
; WIPE_START
G1 F3215.099
G1 X144.529 Y124.477 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.923 Y130.783 Z22.64 F42000
G1 Z22.24
G1 E.8 F1800
G1 F2758
M204 S6000
G2 X143.852 Y130.295 I-1.037 J-3.099 E.1683
G1 X148.08 Y131.601 E.70668
G1 X148.08 Y132.672 E.171
G1 X142.933 Y131.082 E.86019
G1 X142.927 Y130.903 E.02854
; WIPE_START
G1 F3215.099
G1 X143.188 Y130.681 E-.13021
G1 X143.467 Y130.546 E-.11797
G1 X143.852 Y130.295 E-.17446
G1 X144.7 Y130.557 E-.33737
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.64 I.642 J-1.034 P1  F42000
G1 X139.89 Y127.573 Z22.64
G1 Z22.24
G1 E.8 F1800
; FEATURE: Outer wall
G1 F984.716
M204 S5000
G1 X139.874 Y127.653 E.01311
G1 F660
G1 X139.854 Y127.827 E.02789
M106 S201.45
M106 S255
G1 F300
G1 X139.847 Y127.99 E.02615
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F600
G1 X139.847 Y128.01 E.00309
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X139.854 Y128.181 E.02736
M106 S201.45
M106 S255
G1 F900
G1 X139.882 Y128.394 E.03428
M106 S201.45
M106 S255
G1 F1499.256
G1 X139.908 Y128.517 E.0201
G1 F2758
G1 X139.966 Y128.715 E.03296
G1 X140.006 Y128.822 E.01824
G2 X143.286 Y129.835 I2.052 J-.825 E.6276
G1 X143.382 Y129.769 E.01859
G1 X143.491 Y129.682 E.02235
G1 F2250
G1 X143.611 Y129.572 E.02595
G1 F1380
G1 X143.672 Y129.507 E.01421
M106 S201.45
M106 S255
G1 F1140
G1 X148.78 Y131.085 E.85369
M106 S201.45
M106 S255
G1 F2758
G1 X148.78 Y131.533 E.0715
G1 X148.78 Y133.621 E.33341
G1 X130.59 Y128 E3.04007
G1 X148.78 Y122.379 E3.04006
G1 X148.78 Y124.467 E.33341
G1 X148.78 Y124.915 E.0715
G1 F1140
G1 X143.671 Y126.49 E.85367
M106 S201.45
G1 F1800
G1 X143.52 Y126.344 E.03353
G1 F2591.805
G1 X143.426 Y126.265 E.01955
G1 F2758
G1 X143.327 Y126.191 E.01984
G1 X143.286 Y126.165 E.00778
G2 X140.006 Y127.178 I-1.229 J1.836 E.62765
G1 X139.99 Y127.217 E.00666
G1 X139.946 Y127.347 E.02205
G1 X139.916 Y127.456 E.01792
; WIPE_START
G1 F2850
M204 S6000
G1 X139.874 Y127.653 E-.07677
G1 X139.854 Y127.827 E-.06638
G1 X139.847 Y127.99 E-.06224
G1 X139.847 Y128.01 E-.00735
G1 X139.854 Y128.181 E-.06512
G1 X139.882 Y128.394 E-.08157
G1 X139.908 Y128.517 E-.04783
G1 X139.966 Y128.715 E-.07844
G1 X140.006 Y128.822 E-.04342
G1 X140.189 Y129.181 E-.15327
G1 X140.288 Y129.326 E-.06652
G1 X140.308 Y129.347 E-.01109
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.64 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z22.64
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z22.64 F4000
            G39.3 S1
            G0 Z22.64 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X140.214 Y129.799 F42000
G1 Z22.24
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.647982
G1 F2758
M204 S6000
G1 X140.263 Y130.194 E.04787
; LINE_WIDTH: 0.686791
G1 X140.267 Y130.222 E.00368
; LINE_WIDTH: 0.726699
G1 X140.272 Y130.25 E.00394
; LINE_WIDTH: 0.766607
G1 X140.276 Y130.278 E.0042
; LINE_WIDTH: 0.763637
G1 X140.392 Y130.338 E.01924
; LINE_WIDTH: 0.723833
G1 X140.497 Y130.388 E.01603
; LINE_WIDTH: 0.69461
G1 X140.582 Y130.428 E.01227
; LINE_WIDTH: 0.658278
G1 X140.786 Y130.515 E.02724
; LINE_WIDTH: 0.608913
G2 X141.441 Y130.734 I2.319 J-5.85 E.07706
G1 X141.642 Y130.783 E.0231
; LINE_WIDTH: 0.648553
G1 X141.857 Y130.828 E.02646
; LINE_WIDTH: 0.686221
G1 X141.982 Y130.849 E.01639
; LINE_WIDTH: 0.717696
G1 X142.086 Y130.866 E.01428
; LINE_WIDTH: 0.736172
G1 X142.112 Y130.87 E.00375
; LINE_WIDTH: 0.763809
G1 X142.578 Y130.926 E.06885
M204 S10000
G1 X143.561 Y130.91 F42000
; LINE_WIDTH: 0.440827
G1 F2758
M204 S6000
G2 X143.939 Y130.857 I-1.317 J-10.876 E.02792
G1 X147.73 Y132.029 E.29032
; WIPE_START
G1 F3000
G1 X145.819 Y131.438 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z22.64 I1.179 J.302 P1  F42000
G1 X147.73 Y123.971 Z22.64
G1 Z22.24
G1 E.8 F1800
; LINE_WIDTH: 0.443537
G1 F2758
M204 S6000
G1 X143.734 Y125.206 E.30859
M204 S10000
G1 X143.546 Y125.095 F42000
; LINE_WIDTH: 0.244572
G1 F2758
M204 S6000
G1 X144.356 Y125.183 E.02311
; WIPE_START
G1 F3000
G1 X143.546 Y125.095 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.055 Y125.132 Z22.64 F42000
G1 Z22.24
G1 E.8 F1800
; LINE_WIDTH: 0.27743
G1 F2758
M204 S6000
G3 X142.266 Y125.389 I-5.624 J29.45 E.04442
; LINE_WIDTH: 0.233379
G1 X142.383 Y125.417 E.0031
M204 S10000
G1 X142.387 Y125.397 F42000
; LINE_WIDTH: 0.375083
G1 F2758
M204 S6000
G1 X140.966 Y125.16 E.08381
M204 S10000
G1 X140.89 Y125.183 F42000
; LINE_WIDTH: 0.472731
G1 F2758
M204 S6000
G1 X142.389 Y125.374 E.12154
M204 S10000
G1 X142.289 Y125.334 F42000
; LINE_WIDTH: 0.595644
G1 F2758
M204 S6000
G2 X141.461 Y125.261 I-2.223 J20.655 E.0902
G1 X140.857 Y125.457 E.06884
; LINE_WIDTH: 0.642996
G1 X140.654 Y125.54 E.02619
; LINE_WIDTH: 0.677772
G1 X140.55 Y125.588 E.01448
; LINE_WIDTH: 0.710657
G1 X140.423 Y125.647 E.01897
; LINE_WIDTH: 0.743998
G1 X140.349 Y125.684 E.01169
; LINE_WIDTH: 0.772309
G1 X140.276 Y125.722 E.01222
; LINE_WIDTH: 0.767176
G1 X140.272 Y125.749 E.00404
; LINE_WIDTH: 0.728631
G1 X140.268 Y125.776 E.0038
; LINE_WIDTH: 0.690086
G1 X140.264 Y125.803 E.00356
; LINE_WIDTH: 0.650311
G1 X140.215 Y126.199 E.0483
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 22.8
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X140.264 Y125.803 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 41/51
; update layer progress
M73 L41
M991 S0 P40 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z22.8 I-1.191 J-1.218 P1  F42000
G1 X138.464 Y127.564 Z22.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F2265
M204 S6000
G1 X138.446 Y127.999 E.06942
G1 X138.464 Y128.436 E.06986
G1 X137.555 Y128.155 E.15187
G1 X137.555 Y127.845 E.04945
G1 X138.35 Y127.6 E.13282
; WIPE_START
G1 F3215.099
G1 X138.446 Y127.999 E-.15595
G1 X138.464 Y128.436 E-.16626
G1 X137.555 Y128.155 E-.36144
G1 X137.555 Y127.954 E-.07635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.275 Y127.185 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
G1 F2265
M204 S6000
G1 X139.188 Y127.523 E.05567
G2 X139.319 Y128.988 I2.907 J.478 E.23743
G1 X139.528 Y129.497 E.08785
G1 X135.185 Y128.155 E.72593
G1 X135.185 Y127.845 E.04945
G1 X139.526 Y126.503 E.72563
G1 X139.325 Y126.996 E.08498
G1 X139.306 Y127.069 E.01208
; WIPE_START
G1 F3215.099
G1 X139.188 Y127.523 E-.17808
G1 X139.146 Y127.999 E-.18166
G1 X139.192 Y128.515 E-.19674
G1 X139.319 Y128.988 E-.18628
M73 P93 R1
G1 X139.336 Y129.03 E-.01724
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.323 Y125.33 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
G1 F2265
M204 S6000
G1 X148.08 Y123.86 E.79501
G1 X148.08 Y124.931 E.171
G1 X144.276 Y126.107 E.63572
G2 X143.424 Y125.394 I-3.434 J3.243 E.1777
; WIPE_START
G1 F3215.099
G1 X145.324 Y124.768 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.312 Y130.666 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
G1 F2265
M204 S6000
G2 X144.269 Y129.891 I-2.358 J-3.891 E.1973
G1 X148.08 Y131.069 E.63694
G1 X148.08 Y132.14 E.171
G1 X143.426 Y130.702 E.77779
; WIPE_START
G1 F3215.099
G1 X143.944 Y130.216 E-.2698
G1 X144.269 Y129.891 E-.17457
G1 X145.063 Y130.136 E-.31562
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.929 Y127.413 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
; FEATURE: Outer wall
G1 F2265
M204 S5000
G1 X139.884 Y127.637 E.03639
G2 X143.732 Y129.441 I2.176 J.364 E.91461
G1 X143.739 Y129.434 E.00149
G1 X143.841 Y129.304 E.02638
G1 X143.927 Y129.178 E.02433
G1 F1500
G1 X143.988 Y129.072 E.01959
M106 S201.45
M106 S255
G1 F1140
G1 X148.78 Y130.553 E.80087
M106 S201.45
M106 S255
G1 F2265
G1 X148.78 Y131.001 E.0715
G1 X148.78 Y133.089 E.33341
G1 X132.313 Y128 E2.75202
G1 X148.78 Y122.911 E2.75202
G1 X148.78 Y124.999 E.33341
G1 X148.78 Y125.447 E.0715
G1 F1140
G1 X143.989 Y126.928 E.80071
M106 S201.45
G1 F1800
G1 X143.885 Y126.758 E.03183
G1 F2265
G1 X143.758 Y126.588 E.03383
G1 X143.732 Y126.559 E.00618
G2 X139.968 Y127.3 I-1.671 J1.441 E.74242
; WIPE_START
G1 F3215.099
M204 S6000
G1 X139.884 Y127.637 E-.1319
G1 X139.847 Y128 E-.13866
G1 X139.881 Y128.391 E-.14917
G1 X139.927 Y128.587 E-.07647
G1 X140.051 Y128.927 E-.13749
G1 X140.209 Y129.213 E-.12448
G1 X140.212 Y129.217 E-.00183
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z23.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z23.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z23.2 F4000
            G39.3 S1
            G0 Z23.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X139.983 Y129.574 F42000
G1 Z22.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.234144
G1 F2265
M204 S6000
G1 X140.048 Y129.68 E.00322
; LINE_WIDTH: 0.265284
G1 X140.112 Y129.786 E.0041
; LINE_WIDTH: 0.297391
G1 X140.16 Y129.859 E.00353
; LINE_WIDTH: 0.329736
G1 X140.205 Y129.927 E.00389
; LINE_WIDTH: 0.353758
G1 X140.337 Y130.113 E.01216
M204 S10000
G1 X140.592 Y130.149 F42000
; LINE_WIDTH: 0.233984
G1 F2265
M204 S6000
G1 X140.489 Y130.097 E.003
; LINE_WIDTH: 0.277609
G3 X140.06 Y129.87 I5.126 J-10.212 E.01745
M204 S10000
G1 X142.327 Y130.728 F42000
; LINE_WIDTH: 0.286066
G1 F2265
M204 S6000
G2 X142.806 Y130.512 I-4.532 J-10.656 E.01987
; LINE_WIDTH: 0.236336
G1 X142.929 Y130.453 E.00363
M204 S10000
G1 X142.701 Y130.66 F42000
; LINE_WIDTH: 0.354179
G1 F2265
M204 S6000
G3 X142.054 Y130.617 I.808 J-17.125 E.03463
M204 S10000
G1 X142.057 Y130.6 F42000
; LINE_WIDTH: 0.231231
G1 F2265
M204 S6000
G1 X142.21 Y130.622 E.00391
; LINE_WIDTH: 0.268783
G1 X142.289 Y130.631 E.00272
; LINE_WIDTH: 0.284037
G1 X142.682 Y130.673 E.01476
; WIPE_START
G1 F3000
G1 X142.289 Y130.631 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.756 Y130.408 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
; LINE_WIDTH: 0.223235
G1 F2265
M204 S6000
G1 X144.1 Y130.544 E.01575
M204 S10000
G1 X144.241 Y130.418 F42000
; LINE_WIDTH: 0.443515
G1 F2265
M204 S6000
G1 X147.73 Y131.496 E.26941
; WIPE_START
G1 F3000
G1 X145.819 Y130.906 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z23.2 I1.166 J.348 P1  F42000
G1 X147.73 Y124.504 Z23.2
G1 Z22.8
G1 E.8 F1800
; LINE_WIDTH: 0.441858
G1 F2265
M204 S6000
G1 X144.421 Y125.526 E.2542
G1 X144.108 Y125.454 E.02359
; WIPE_START
G1 F3000
G1 X144.421 Y125.526 E-.12214
G1 X146.025 Y125.031 E-.63786
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.985 Y125.571 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
; LINE_WIDTH: 0.231122
G1 F2265
M204 S6000
G1 X142.853 Y125.501 E.00376
; LINE_WIDTH: 0.268595
G1 X142.733 Y125.444 E.0045
; LINE_WIDTH: 0.316619
G1 X142.613 Y125.388 E.00595
; LINE_WIDTH: 0.364057
G1 X142.331 Y125.271 E.017
M204 S10000
G1 X142.056 Y125.4 F42000
; LINE_WIDTH: 0.223826
G1 F2265
M204 S6000
G1 X142.141 Y125.386 E.00203
; LINE_WIDTH: 0.252687
G1 X142.266 Y125.372 E.00381
; LINE_WIDTH: 0.299349
G1 X142.386 Y125.359 E.00494
; LINE_WIDTH: 0.324029
G1 X142.721 Y125.33 E.01565
M204 S10000
G1 X140.048 Y126.152 F42000
; LINE_WIDTH: 0.34483
G1 F2265
M204 S6000
G1 X140.283 Y126.012 E.01403
; LINE_WIDTH: 0.304127
G1 X140.391 Y125.954 E.0051
; LINE_WIDTH: 0.259553
G1 X140.49 Y125.901 E.00357
; LINE_WIDTH: 0.227958
G1 X140.592 Y125.852 E.00279
M204 S10000
G1 X140.316 Y125.893 F42000
; LINE_WIDTH: 0.293289
G1 F2265
M204 S6000
G1 X140.124 Y126.193 E.01404
; LINE_WIDTH: 0.273499
G1 X140.051 Y126.312 E.00489
; LINE_WIDTH: 0.236883
G1 X139.978 Y126.432 E.00373
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 23.36
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3000
G1 X140.051 Y126.312 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 42/51
; update layer progress
M73 L42
M991 S0 P41 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z23.36 I-1.274 J-1.131 P1  F42000
G1 X139.248 Y127.218 Z23.36
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F1820
M204 S6000
G1 X139.189 Y127.508 E.04741
G2 X139.276 Y128.887 I3.089 J.496 E.22232
G1 X136.908 Y128.155 E.39575
G1 X136.908 Y127.845 E.04945
G1 X139.253 Y127.12 E.39194
; WIPE_START
G1 F3215.099
G1 X139.189 Y127.508 E-.14949
G1 X139.157 Y127.747 E-.09127
G1 X139.156 Y128.241 E-.18776
G1 X139.19 Y128.504 E-.1008
G1 X139.276 Y128.887 E-.14909
G1 X139.071 Y128.823 E-.0816
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.866 Y125.695 Z23.76 F42000
G1 Z23.36
G1 E.8 F1800
G1 F1820
M204 S6000
G1 X148.08 Y124.393 E.7043
G1 X148.08 Y125.464 E.171
G1 X144.58 Y126.545 E.58498
G2 X143.953 Y125.778 I-3.688 J2.372 E.15861
; WIPE_START
G1 F3215.099
G1 X145.849 Y125.141 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z23.76 I-1.137 J-.433 P1  F42000
G1 X143.879 Y130.309 Z23.76
G1 Z23.36
G1 E.8 F1800
G1 F1820
M204 S6000
G2 X144.584 Y129.456 I-3.093 J-3.271 E.17712
G1 X148.08 Y130.536 E.5843
G1 X148.08 Y131.607 E.171
G1 X143.994 Y130.345 E.68288
; WIPE_START
G1 F3215.099
G1 X144.279 Y129.88 E-.20701
G1 X144.584 Y129.456 E-.19857
G1 X145.475 Y129.731 E-.35442
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.955 Y127.326 Z23.76 F42000
G1 Z23.36
G1 E.8 F1800
; FEATURE: Outer wall
G1 F1820
M204 S5000
G1 X139.947 Y127.369 E.00698
G2 X144.028 Y128.999 I2.114 J.632 E1.04343
G1 X144.103 Y128.837 E.02861
G1 X144.16 Y128.681 E.02651
G1 F1380
G1 X144.183 Y128.6 E.01348
M106 S201.45
M106 S255
G1 F1140
G1 X148.78 Y130.02 E.76829
M106 S201.45
M106 S255
G1 F1820
G1 X148.78 Y130.468 E.07151
G1 X148.78 Y132.556 E.33341
G1 X134.037 Y128 E2.46398
G1 X148.78 Y123.444 E2.46398
G1 X148.78 Y125.532 E.33341
G1 X148.78 Y125.98 E.07151
G1 F1140
G1 X144.183 Y127.4 E.7682
M106 S201.45
M106 S255
G1 F1260
G1 X144.173 Y127.362 E.0063
M106 S201.45
G1 F1800
G1 X144.135 Y127.249 E.01909
G1 F1820
G1 X144.099 Y127.155 E.01608
M73 P94 R1
G1 X144.027 Y127.001 E.02715
G2 X140.052 Y127.089 I-1.966 J1 E.7908
G1 X140 Y127.215 E.02173
; WIPE_START
G1 F3215.099
M204 S6000
G1 X139.947 Y127.369 E-.06191
G1 X139.879 Y127.624 E-.10023
G1 X139.847 Y127.999 E-.14309
G1 X139.88 Y128.382 E-.14604
G1 X139.98 Y128.757 E-.14747
G1 X140.105 Y129.037 E-.1164
G1 X140.167 Y129.137 E-.04486
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z23.76 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z23.76
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z23.76 F4000
            G39.3 S1
            G0 Z23.76 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X139.949 Y129.461 F42000
G1 Z23.36
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.239052
G1 F1820
M204 S6000
G1 X139.805 Y129.348 E.00497
G1 X139.749 Y129.203 E.00424
M204 S10000
G1 X139.724 Y126.847 F42000
; LINE_WIDTH: 0.246697
G1 F1820
M204 S6000
G1 X139.791 Y126.663 E.00565
G1 X139.947 Y126.54 E.00574
; WIPE_START
G1 F3000
G1 X139.791 Y126.663 E-.38287
G1 X139.724 Y126.847 E-.37713
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.108 Y125.563 Z23.76 F42000
G1 Z23.36
G1 E.8 F1800
; LINE_WIDTH: 0.261627
G1 F1820
M204 S6000
G1 X143.241 Y125.657 E.00527
; LINE_WIDTH: 0.234178
G1 X143.369 Y125.752 E.00413
; WIPE_START
G1 F3000
G1 X143.241 Y125.657 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.626 Y125.996 Z23.76 F42000
G1 Z23.36
M73 P94 R0
G1 E.8 F1800
; LINE_WIDTH: 0.443529
G1 F1820
M204 S6000
G1 X147.73 Y125.036 E.23973
; WIPE_START
G1 F3000
G1 X145.819 Y125.627 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z23.76 I-1.146 J.41 P1  F42000
G1 X147.73 Y130.964 Z23.76
G1 Z23.36
G1 E.8 F1800
; LINE_WIDTH: 0.443521
G1 F1820
M204 S6000
G1 X144.791 Y130.055 E.22694
; LINE_WIDTH: 0.419704
G1 X144.783 Y130.028 E.00198
; LINE_WIDTH: 0.372062
G1 X144.774 Y130 E.00166
; LINE_WIDTH: 0.324421
G1 X144.765 Y129.973 E.00135
; LINE_WIDTH: 0.292147
G1 X144.731 Y129.867 E.00435
; WIPE_START
G1 F3000
G1 X144.765 Y129.973 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.445 Y130.201 Z23.76 F42000
G1 Z23.36
G1 E.8 F1800
; LINE_WIDTH: 0.234079
G1 F1820
M204 S6000
G1 X143.346 Y130.279 E.00327
; LINE_WIDTH: 0.277761
G1 X143.128 Y130.443 E.00981
; CHANGE_LAYER
; Z_HEIGHT: 23.92
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X143.346 Y130.279 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 43/51
; update layer progress
M73 L43
M991 S0 P42 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z23.92 I.898 J-1.448 P1  F42000
G1 X139.161 Y127.682 Z23.92
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F1336
M204 S6000
G1 X139.146 Y127.997 E.05041
G1 X139.159 Y128.318 E.05128
G1 X138.632 Y128.155 E.08819
G1 X138.632 Y127.845 E.04946
G1 X139.046 Y127.717 E.06926
M204 S250
G1 X139.95 Y127.359 F42000
M106 S255
; FEATURE: Outer wall
G1 F1336
M204 S5000
G1 X139.88 Y127.666 E.05028
G2 X140.366 Y129.423 I2.214 J.333 E.29985
G1 X135.76 Y128 E.76982
G1 X140.367 Y126.576 E.76999
G1 X140.287 Y126.677 E.02062
G2 X139.986 Y127.245 I1.808 J1.322 E.10295
; WIPE_START
G1 F3215.099
M204 S6000
G1 X139.88 Y127.666 E-.16515
G1 X139.847 Y127.999 E-.12701
G1 X139.871 Y128.323 E-.12362
G1 X139.985 Y128.767 E-.17421
G1 X140.164 Y129.14 E-.15708
G1 X140.183 Y129.168 E-.01293
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.454 Y126.364 Z24.32 F42000
G1 Z23.92
G1 E.8 F1800
; FEATURE: Inner wall
G1 F1336
M204 S6000
G1 X144.269 Y126.103 E.05106
G1 X148.08 Y124.925 E.63694
G1 X148.08 Y125.996 E.171
G1 X144.803 Y127.009 E.54763
G2 X144.55 Y126.509 I-3.582 J1.503 E.08953
G1 X144.52 Y126.464 E.00865
; WIPE_START
G1 F3215.099
G1 X144.269 Y126.103 E-.16709
G1 X145.76 Y125.642 E-.59291
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z24.32 I-1.17 J-.334 P1  F42000
G1 X144.805 Y128.992 Z24.32
G1 Z23.92
G1 E.8 F1800
G1 F1336
M204 S6000
G1 X148.08 Y130.004 E.5474
G1 X148.08 Y131.075 E.171
G1 X144.283 Y129.901 E.63461
G2 X144.756 Y129.101 I-3.674 J-2.712 E.14866
; WIPE_START
G1 F3215.099
G1 X146.686 Y129.625 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.12 Y127.218 Z24.32 F42000
G1 Z23.92
G1 E.8 F1800
; FEATURE: Outer wall
G1 F1336
M204 S5000
G1 X144.101 Y127.16 E.00972
G2 X142.646 Y125.872 I-2.043 J.842 E.32126
G1 X148.78 Y123.977 E1.02514
G1 X148.78 Y126.065 E.33341
G1 X148.78 Y126.512 E.0715
G1 F1140
G1 X145.444 Y127.543 E.5575
M106 S201.45
M106 S255
G1 X145.062 Y127.661 E.06387
M106 S201.45
M106 S255
G1 F300
G1 X145.062 Y127.977 E.05033
M106 S201.45
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X145.062 Y128.023 E.00747
M106 S201.45
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X145.062 Y128.339 E.05033
M106 S201.45
M106 S255
G1 F1140
G1 X145.444 Y128.457 E.06387
M106 S201.45
M106 S255
G1 X148.78 Y129.488 E.5575
M106 S201.45
M106 S255
G1 F1336
G1 X148.78 Y129.935 E.0715
G1 X148.78 Y132.023 E.33341
G1 X142.646 Y130.128 E1.02513
G2 X144.205 Y128.521 I-.624 J-2.165 E.374
G1 X144.207 Y128.514 E.00118
G1 X144.24 Y128.35 E.02682
G1 X144.26 Y128.181 E.02706
G1 F1140
G2 X144.26 Y127.815 I-2.204 J-.182 E.05858
M106 S201.45
G1 F1336
G1 X144.23 Y127.596 E.03531
G1 X144.205 Y127.479 E.01915
G1 X144.204 Y127.474 E.0008
G1 X144.158 Y127.332 E.0238
; WIPE_START
G1 F3215.099
M204 S6000
G1 X144.101 Y127.16 E-.06874
G1 X143.954 Y126.865 E-.12514
G1 X143.762 Y126.594 E-.12636
G1 X143.634 Y126.452 E-.07265
G1 X143.46 Y126.293 E-.08941
G1 X143.173 Y126.092 E-.13336
G1 X142.926 Y125.968 E-.10484
G1 X142.828 Y125.934 E-.0395
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z24.32 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z24.32
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z24.32 F4000
            G39.3 S1
            G0 Z24.32 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X144.995 Y126.584 F42000
G1 Z23.92
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.33023
G1 F1336
M204 S6000
G1 X145.05 Y126.452 E.00686
; LINE_WIDTH: 0.356529
G1 X145.059 Y126.431 E.00121
; LINE_WIDTH: 0.391327
G1 X145.067 Y126.41 E.00139
; LINE_WIDTH: 0.426125
G1 X145.075 Y126.389 E.00156
; LINE_WIDTH: 0.443524
G1 X147.73 Y125.569 E.20502
; WIPE_START
G1 F3000
G1 X145.819 Y126.159 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.633 Y127.428 Z24.32 F42000
G1 Z23.92
G1 E.8 F1800
; LINE_WIDTH: 0.238091
G1 F1336
M204 S6000
G1 X144.664 Y127.954 E.01417
M204 S10000
G1 X144.664 Y128.047 F42000
; LINE_WIDTH: 0.237107
G1 F1336
M204 S6000
G1 X144.633 Y128.572 E.01404
M204 S10000
G1 X144.997 Y129.417 F42000
; LINE_WIDTH: 0.370117
G1 F1336
M204 S6000
G1 X145.062 Y129.575 E.00977
; LINE_WIDTH: 0.398978
G1 X145.069 Y129.593 E.0012
; LINE_WIDTH: 0.428687
G1 X145.076 Y129.611 E.00133
; LINE_WIDTH: 0.443528
G1 X147.73 Y130.431 E.20497
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 24.48
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3000
G1 X145.819 Y129.841 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 44/51
; update layer progress
M73 L44
M991 S0 P43 ;notify layer change
M106 S255
; OBJECT_ID: 15
M204 S10000
G17
G3 Z24.48 I1.597 J-.595 P1  F42000
G1 X144.889 Y127.341 Z24.48
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F1200
M204 S6000
G1 X144.878 Y127.3 E.00672
G2 X144.588 Y126.537 I-2.983 J.695 E.13073
G1 X148.08 Y125.458 E.58361
G1 X148.08 Y126.529 E.171
G1 X146.468 Y127.027 E.26946
G1 X146.086 Y127.145 E.06387
G1 X146.086 Y127.43 E.04545
G1 F420
G1 X146.086 Y128.57 E.18207
M106 S204
M106 S255
G1 F1200
G1 X146.086 Y128.855 E.04545
G1 X146.468 Y128.973 E.06387
G1 X148.08 Y129.471 E.26946
G1 X148.08 Y130.542 E.171
G1 X144.584 Y129.462 E.58436
G2 X144.948 Y127.754 I-2.689 J-1.466 E.28266
G1 X144.906 Y127.46 E.04753
M204 S250
G1 X144.156 Y127.34 F42000
; FEATURE: Outer wall
G1 F1200
M204 S5000
G1 X144.039 Y127.036 E.0519
G2 X143.329 Y126.194 I-1.999 J.964 E.17782
G1 X148.78 Y124.509 E.91092
G1 X148.78 Y126.597 E.33341
G1 X148.78 Y127.045 E.0715
G1 F1140
G1 X147.168 Y127.543 E.26946
M106 S204
M106 S255
G1 X146.786 Y127.661 E.06387
M106 S204
M106 S255
G1 F300
G1 X146.786 Y127.977 E.05033
M106 S204
M106 S255
; FEATURE: Overhang wall
M73 P95 R0
G1 F1800
G1 X146.786 Y128.023 E.00746
M106 S204
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X146.786 Y128.339 E.05033
M106 S204
M106 S255
G1 F1140
G1 X147.168 Y128.457 E.06387
M106 S204
M106 S255
G1 X148.78 Y128.955 E.26946
M106 S204
G1 F1200
G1 X148.78 Y129.403 E.07151
G1 X148.78 Y131.491 E.33341
G1 X143.329 Y129.806 E.91097
G2 X144.196 Y127.47 I-1.289 J-1.807 E.42238
G1 X144.191 Y127.455 E.00264
; WIPE_START
G1 F3215.099
M204 S6000
G1 X144.039 Y127.036 E-.16904
G1 X143.857 Y126.718 E-.13945
G1 X143.766 Y126.599 E-.05701
G1 X143.539 Y126.36 E-.12523
G1 X143.329 Y126.194 E-.10164
G1 X143.751 Y126.063 E-.16764
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z24.88 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z24.88
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z24.88 F4000
            G39.3 S1
            G0 Z24.88 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X145.447 Y126.947 F42000
G1 Z24.48
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.685114
G1 F1200
M204 S6000
G1 X145.46 Y127.045 E.01281
; LINE_WIDTH: 0.655841
G1 X145.476 Y127.159 E.01406
; LINE_WIDTH: 0.616747
G1 X145.499 Y127.38 E.02521
; LINE_WIDTH: 0.571186
G3 X145.521 Y127.714 I-7.111 J.637 E.03439
; LINE_WIDTH: 0.551047
G3 X145.504 Y128.561 I-7.893 J.265 E.0833
; LINE_WIDTH: 0.607938
G1 X145.48 Y128.809 E.02775
; LINE_WIDTH: 0.635004
G1 X145.477 Y128.831 E.00265
; LINE_WIDTH: 0.653771
G1 X145.461 Y128.944 E.01389
; LINE_WIDTH: 0.685919
G1 X145.445 Y129.057 E.01472
; LINE_WIDTH: 0.681361
G1 X145.465 Y129.085 E.00445
; LINE_WIDTH: 0.640129
G1 X145.486 Y129.113 E.00412
; LINE_WIDTH: 0.597522
G1 X145.537 Y129.151 E.00692
; LINE_WIDTH: 0.553533
G1 X145.587 Y129.19 E.00628
; LINE_WIDTH: 0.509544
G1 X145.638 Y129.229 E.00565
; LINE_WIDTH: 0.444176
G1 X145.688 Y129.267 E.0047
G1 X147.73 Y129.898 E.15802
; WIPE_START
G1 F3000
G1 X145.819 Y129.308 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.447 Y126.947 Z24.88 F42000
G1 Z24.48
G1 E.8 F1800
; LINE_WIDTH: 0.682435
G1 F1200
M204 S6000
G1 X145.466 Y126.914 E.00483
; LINE_WIDTH: 0.639648
G1 X145.486 Y126.887 E.00402
; LINE_WIDTH: 0.597498
G1 X145.537 Y126.848 E.00692
; LINE_WIDTH: 0.553514
G1 X145.587 Y126.81 E.00628
; LINE_WIDTH: 0.50953
G1 X145.638 Y126.771 E.00565
; LINE_WIDTH: 0.465546
G1 X145.688 Y126.733 E.00501
; LINE_WIDTH: 0.443538
G1 X147.73 Y126.102 E.15771
; WIPE_START
G1 F3000
G1 X145.819 Y126.692 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.988 Y127.226 Z24.88 F42000
G1 Z24.48
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.82
G1 F1200
M204 S5000
G1 X139.939 Y127.369 E.02413
G2 X139.987 Y128.774 I2.15 J.63 E.22828
G1 X137.484 Y128 E.41835
G1 X139.874 Y127.261 E.39942
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 25.04
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.099
M204 S6000
G1 X139.939 Y127.369 E-.04775
G1 X139.872 Y127.666 E-.11582
G1 X139.847 Y127.999 E-.12664
G1 X139.872 Y128.333 E-.12748
G1 X139.987 Y128.774 E-.17296
G1 X139.561 Y128.642 E-.16935
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 45/51
; update layer progress
M73 L45
M991 S0 P44 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z25.04 I.32 J1.673 P1  F42000
G1 X145.631 Y127.48 Z25.04
G1 E.8 F1800
; FEATURE: Inner wall
G1 F1200
M204 S6000
G1 X147.109 Y127.023 E.24711
G1 X147.109 Y127.246 E.03562
G1 X147.109 Y127.646 E.06387
G1 X147.109 Y128.354 E.11301
G1 X147.109 Y128.754 E.06387
G1 X147.109 Y128.977 E.03563
G1 X145.629 Y128.519 E.24744
G2 X145.646 Y127.599 I-3.61 J-.527 E.1474
M204 S10000
G1 X144.905 Y127.411 F42000
G1 F1200
M204 S6000
G1 X144.795 Y127.006 E.06712
G1 X148.08 Y125.991 E.549
G1 X148.08 Y127.061 E.171
G1 X147.809 Y127.145 E.04529
G1 X147.809 Y127.43 E.04545
G1 F420
G1 X147.809 Y128.57 E.18207
M106 S204
M106 S255
G1 F1200
G1 X147.809 Y128.855 E.04546
G1 X148.08 Y128.939 E.04529
G1 X148.08 Y130.009 E.17099
G1 X144.794 Y128.994 E.54921
G2 X144.922 Y127.53 I-2.95 J-.996 E.23686
M204 S250
G1 X144.219 Y127.551 F42000
; FEATURE: Outer wall
G1 F1200
M204 S5000
G1 X144.145 Y127.293 E.04279
G2 X143.761 Y126.593 I-2.119 J.706 E.12822
G1 X148.78 Y125.042 E.83882
G1 X148.78 Y127.13 E.33341
G1 X148.78 Y127.578 E.07151
G1 F1140
G1 X148.509 Y127.661 E.04529
M106 S204
M106 S255
G1 F300
G1 X148.509 Y127.977 E.05033
M106 S204
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X148.509 Y128.023 E.00746
M106 S204
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X148.509 Y128.339 E.05033
M106 S204
M106 S255
G1 F1140
G1 X148.78 Y128.422 E.04529
M106 S204
G1 F1200
G1 X148.78 Y128.87 E.0715
G1 X148.78 Y130.958 E.33341
G1 X143.76 Y129.407 E.83891
G2 X144.235 Y127.669 I-1.735 J-1.407 E.29603
; WIPE_START
G1 F3215.099
M204 S6000
G1 X144.145 Y127.293 E-.14703
G1 X143.959 Y126.874 E-.17443
G1 X143.761 Y126.593 E-.13053
G1 X144.535 Y126.354 E-.30802
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.901 Y127.745 Z25.44 F42000
G1 Z25.04
G1 E.8 F1800
; LINE_WIDTH: 0.74301
G1 F1200
M204 S5000
G1 X139.895 Y127.793 E.00681
G2 X139.902 Y128.255 I2.437 J.197 E.06578
G1 X139.077 Y128 E.12273
G1 X139.787 Y127.781 E.10557
; WIPE_START
G1 F3612.527
M204 S6000
G1 X139.895 Y127.793 E-.0416
G1 X139.885 Y128 E-.07866
G1 X139.902 Y128.255 E-.09727
G1 X139.077 Y128 E-.32817
G1 X139.616 Y127.833 E-.2143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z25.44 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z25.44
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z25.44 F4000
            G39.3 S1
            G0 Z25.44 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; CHANGE_LAYER
; Z_HEIGHT: 25.6
; LAYER_HEIGHT: 0.559999
; layer num/total_layer_count: 46/51
; update layer progress
M73 L46
M991 S0 P45 ;notify layer change
; OBJECT_ID: 15
G1 X146.172 Y127.845 F42000
G1 Z25.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F1200
M204 S6000
G1 X147.38 Y127.472 E.20188
G1 X147.38 Y128.528 E.16866
G1 X146.172 Y128.155 E.20188
G1 X146.172 Y127.965 E.03029
; WIPE_START
G1 F3215.099
G1 X147.38 Y127.472 E-.49583
G1 X147.38 Y128.167 E-.26417
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.923 Y127.499 Z26 F42000
G1 Z25.6
G1 E.8 F1800
G1 F1200
M204 S6000
M73 P96 R0
G1 X148.08 Y126.523 E.52764
G1 X148.08 Y129.477 E.47164
G1 X144.926 Y128.502 E.5272
G2 X144.937 Y127.618 I-3.838 J-.492 E.1415
M204 S250
G1 X144.192 Y127.434 F42000
; FEATURE: Outer wall
G1 F1200
M204 S5000
G2 X144.046 Y127.037 I-2.148 J.565 E.06768
G1 X148.78 Y125.574 E.79116
G1 X148.78 Y127.662 E.33341
G1 X148.78 Y128.338 E.10779
G1 X148.78 Y130.426 E.33341
G1 X144.045 Y128.963 E.79128
G2 X144.22 Y127.551 I-2.001 J-.963 E.23112
; WIPE_START
G1 F3215.099
M204 S6000
G1 X144.046 Y127.037 E-.20616
G1 X145.439 Y126.607 E-.55384
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z26 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z26
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z26 F4000
            G39.3 S1
            G0 Z26 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; CHANGE_LAYER
; Z_HEIGHT: 26.16
; LAYER_HEIGHT: 0.559999
; layer num/total_layer_count: 47/51
; update layer progress
M73 L47
M991 S0 P46 ;notify layer change
; OBJECT_ID: 15
G1 X145.526 Y127.845 F42000
G1 Z26.16
G1 E.8 F1800
; FEATURE: Inner wall
G1 F1200
M204 S6000
G1 X148.08 Y127.056 E.42694
G1 X148.08 Y128.944 E.30155
G1 X145.526 Y128.155 E.42694
G1 X145.526 Y127.965 E.03029
; WIPE_START
G1 F3215.099
G1 X147.41 Y127.294 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.213 Y127.518 Z26.56 F42000
G1 Z26.16
G1 E.8 F1800
; FEATURE: Outer wall
G1 F1200
M204 S5000
G1 X148.78 Y126.107 E.76324
G1 X148.78 Y129.893 E.60453
G1 X144.214 Y128.482 E.76313
G2 X144.236 Y127.636 I-2.202 J-.48 E.13591
; WIPE_START
G1 F3215.099
M204 S6000
G1 X146.131 Y126.998 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z26.56 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z26.56
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z26.56 F4000
            G39.3 S1
            G0 Z26.56 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; CHANGE_LAYER
; Z_HEIGHT: 26.72
; LAYER_HEIGHT: 0.559999
; layer num/total_layer_count: 48/51
; update layer progress
M73 L48
M991 S0 P47 ;notify layer change
; OBJECT_ID: 15
G1 X147.249 Y128 F42000
G1 Z26.72
G1 E.8 F1800
; FEATURE: Inner wall
G1 F1200
M204 S6000
G1 X147.249 Y127.845 E.02473
G1 X148.08 Y127.588 E.1389
G1 X148.08 Y128.412 E.13147
G1 X147.249 Y128.155 E.1389
G1 X147.249 Y128.12 E.00557
; WIPE_START
G1 F3215.099
G1 X147.249 Y127.845 E-.10445
G1 X148.08 Y127.588 E-.33055
G1 X148.08 Y128.412 E-.31288
G1 X148.05 Y128.402 E-.01212
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.378 Y128 Z27.12 F42000
G1 Z26.72
G1 E.8 F1800
; FEATURE: Outer wall
G1 F1200
M204 S5000
G1 X148.78 Y126.64 E.73574
G1 X148.78 Y129.36 E.43445
G1 X144.492 Y128.035 E.71658
; WIPE_START
G1 F3215.099
M204 S6000
G1 X146.394 Y127.416 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z27.12 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z27.12
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z27.12 F4000
            G39.3 S1
            G0 Z27.12 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; CHANGE_LAYER
; Z_HEIGHT: 27.28
; LAYER_HEIGHT: 0.560001
; layer num/total_layer_count: 49/51
; update layer progress
M73 L49
M991 S0 P48 ;notify layer change
; OBJECT_ID: 15
M204 S250
G1 X146.101 Y128 F42000
G1 Z27.28
G1 E.8 F1800
G1 F1200
M204 S5000
G1 X148.78 Y127.172 E.4477
G1 X148.78 Y128.828 E.26436
G1 X146.216 Y128.035 E.42854
; WIPE_START
G1 F3215.099
M204 S6000
G1 X148.111 Y127.397 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z27.68 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z27.68
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z27.68 F4000
            G39.3 S1
            G0 Z27.68 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; CHANGE_LAYER
; Z_HEIGHT: 27.84
; LAYER_HEIGHT: 0.559999
; layer num/total_layer_count: 50/51
; update layer progress
M73 L50
M991 S0 P49 ;notify layer change
; OBJECT_ID: 15
M204 S250
G1 X147.694 Y128 F42000
G1 Z27.84
G1 E.8 F1800
; LINE_WIDTH: 0.74301
G1 F1200
M204 S5000
G1 X148.818 Y127.653 E.16722
G1 X148.818 Y128.347 E.09874
G1 X147.809 Y128.035 E.15016
; WIPE_START
G1 F3612.527
M204 S6000
G1 X148.818 Y127.653 E-.4103
G1 X148.818 Y128.347 E-.26403
G1 X148.603 Y128.281 E-.08568
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z28.24 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z28.24
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z28.24 F4000
            G39.3 S1
            G0 Z28.24 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; close powerlost recovery
M1003 S0
M106 S0
M981 S0 P20000 ; close spaghetti detector
; FEATURE: Custom
; MACHINE_END_GCODE_START
; filament end gcode 

;===== date: 20260513 =====================
G392 S0 ;turn off nozzle clog detect

M400 ; wait for buffer to clear
G92 E0 ; zero the extruder
G90
G1 Z28.24 F900 ; lower z a little
G1 X0 Y128 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos

M1002 judge_flag timelapse_record_flag
M622 J1
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M991 S0 P-1 ;end timelapse at safe pos
M623


M140 S0 ; turn off bed
M106 S0 ; turn off fan
M106 P2 S0 ; turn off remote part cooling fan
M106 P3 S0 ; turn off chamber cooling fan

;G1 X27 F15000 ; wipe

; pull back filament to AMS
M620 S255
G1 X267 F15000
T255
G1 X-28.5 F18000
G1 X-48.2 F3000
G1 X-28.5 F18000
G1 X-48.2 F3000
M621 S255

M104 S0 ; turn off hotend

M400 ; wait all motion done
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom

    G1 Z127.84 F600
    G1 Z125.84

M400 P100
M17 R ; restore z current

G90
G1 X-48 Y180 F3600

M220 S100  ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

;=====printer finish  sound=========
M17
M400 S1
M1006 S1
M1006 A0 B20 L100 C37 D20 M40 E42 F20 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C46 D10 M80 E46 F10 N80
M1006 A44 B20 L100 C39 D20 M60 E48 F20 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C39 D10 M60 E39 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C39 D10 M60 E39 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C48 D10 M60 E44 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10  N80
M1006 A44 B20 L100 C49 D20 M80 E41 F20 N80
M1006 A0 B20 L100 C0 D20 M60 E0 F20 N80
M1006 A0 B20 L100 C37 D20 M30 E37 F20 N60
M1006 W
;=====printer finish  sound=========

;M17 X0.8 Y0.8 Z0.5 ; lower motor current to 45% power
M400
M18 X Y Z

M73 P100 R0
; EXECUTABLE_BLOCK_END

