; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 12m 38s; total estimated time: 18m 52s
; total layer number: 51
; total filament length [mm] : 4222.79
; total filament volume [cm^3] : 10157.01
; total filament weight [g] : 12.80
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
M73 P0 R18
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
M73 P3 R18
G1 E-0.5 F300

G1 X-28.5 F30000
M73 P4 R18
G1 X-48.2 F3000
M73 P5 R17
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
M73 P6 R17
    G1 X-48.2 F3000
M73 P7 R17
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
    
M73 P8 R17
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
M73 P31 R12
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
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

G90
G1 X30 Y250.000 F30000
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X35 F30000
M73 P32 R12
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
    G29 A1 X106.808 Y117 I42.3845 J21.9995
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
G1 X138.313 Y127.901 F42000
M204 S6000
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F2100
M204 S500
G1 X138.323 Y127.668 E.02797
G3 X141.889 Y124.25 I3.736 J.329 E.64511
G1 X142.111 Y124.246 E.02655
G3 X138.31 Y128.11 I-.051 J3.75 E2.09508
G1 X138.312 Y128.021 E.01064
M204 S6000
G1 X139.052 Y127.912 F42000
G1 F2100
M204 S500
G1 X139.076 Y127.548 E.04366
G3 X141.922 Y124.984 I2.983 J.45 E.4966
G1 X142.101 Y124.981 E.02132
G3 X139.044 Y128.089 I-.041 J3.017 E1.68521
G1 X139.046 Y128.032 E.00683
M204 S6000
G1 X139.782 Y127.956 F42000
; FEATURE: Outer wall
G1 F2100
M204 S500
G1 X139.801 Y127.657 E.0359
G3 X141.956 Y125.717 I2.257 J.341 E.37574
G1 X142.09 Y125.715 E.01609
G3 X139.777 Y128.076 I-.031 J2.283 E1.27425
; WIPE_START
G1 X139.801 Y127.657 E-.15959
G1 X139.856 Y127.394 E-.10196
G1 X139.944 Y127.136 E-.10351
G1 X140.134 Y126.769 E-.15723
M73 P33 R12
G1 X140.385 Y126.445 E-.15564
G1 X140.541 Y126.296 E-.08207
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X133.289 Y123.916 Z.8 F42000
G1 X123.666 Y120.759 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F2100
M204 S500
G1 X124.058 Y120.844 E.04804
G2 X124.741 Y120.904 I.72 J-4.337 E.08211
G1 X146.763 Y120.904 E2.6349
G1 X146.945 Y120.931 E.02196
G1 X147.099 Y121.026 E.02162
G1 X147.202 Y121.173 E.0215
G1 X147.239 Y121.379 E.02503
G1 X147.239 Y134.621 E1.58438
G1 X147.226 Y134.753 E.01585
G1 X147.191 Y134.85 E.01234
G1 X147.116 Y134.957 E.01559
G1 X147.015 Y135.036 E.01538
G1 X146.895 Y135.084 E.01552
G1 X146.763 Y135.097 E.0158
G1 X124.741 Y135.097 E2.63491
G2 X122.715 Y135.611 I.037 J4.396 E.2526
G3 X109.897 Y132.388 I-4.888 J-7.659 E1.77069
G3 X118.166 Y118.966 I7.907 J-4.387 E2.29082
G3 X122.715 Y120.389 I-.387 J9.216 E.57687
G2 X123.55 Y120.729 I2.063 J-3.883 E.10804
M204 S6000
G1 X123.828 Y120.044 F42000
G1 F2100
M204 S500
G1 X124.178 Y120.12 E.04287
G2 X124.752 Y120.169 I.599 J-3.608 E.06894
G1 X146.774 Y120.169 E2.63499
G3 X147.973 Y121.368 I.015 J1.184 E.22614
G1 X147.973 Y134.632 E1.58699
G3 X146.774 Y135.831 I-1.184 J.015 E.22615
G1 X124.752 Y135.831 E2.63498
G2 X123.061 Y136.259 I.025 J3.656 E.21073
G3 X118.195 Y118.232 I-5.247 J-8.254 E4.3848
G3 X123.061 Y119.742 I-.413 J9.927 E.61646
G2 X123.713 Y120.011 I1.716 J-3.229 E.08453
M204 S6000
G1 X123.991 Y119.327 F42000
; FEATURE: Outer wall
G1 F2100
M204 S500
G2 X124.762 Y119.435 I.786 J-2.81 E.09348
G1 X146.785 Y119.435 E2.63505
G3 X148.707 Y121.358 I.005 J1.917 E.36152
G1 X148.707 Y134.643 E1.58959
G3 X146.785 Y136.565 I-1.917 J.005 E.3615
G1 X124.762 Y136.565 E2.63507
G2 X123.407 Y136.907 I.014 J2.917 E.16885
G3 X118.224 Y117.498 I-5.594 J-8.902 E4.7072
G3 X123.407 Y119.094 I-.439 J10.642 E.65608
G2 X123.876 Y119.293 I1.369 J-2.576 E.061
; WIPE_START
G1 X124.298 Y119.397 E-.16526
G1 X124.762 Y119.435 E-.17695
G1 X125.861 Y119.435 E-.41779
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


G1 X145.399 Y121.197 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.829831
G1 F3300
M204 S500
G1 X146.615 Y122.413 E.20855
G1 X146.615 Y123.465 E.12758
G1 X144.677 Y121.527 E.33235
G1 X143.624 Y121.527 E.12761
G1 X146.615 Y124.517 E.51282
G1 X146.615 Y125.57 E.12758
G1 X142.572 Y121.526 E.69328
G1 X141.52 Y121.526 E.12761
G1 X144.159 Y124.166 E.45269
G2 X142.597 Y123.656 I-2.192 J4.066 E.20031
M73 P34 R12
G1 X140.467 Y121.526 E.36529
G1 X139.415 Y121.526 E.12761
G1 X141.547 Y123.658 E.36573
G2 X140.685 Y123.848 I.358 J3.691 E.10737
G1 X138.362 Y121.525 E.39823
G1 X137.31 Y121.525 E.12761
G1 X139.95 Y124.165 E.45274
G2 X139.322 Y124.59 I2.803 J4.823 E.09195
G1 X136.257 Y121.525 E.52555
G1 X135.205 Y121.525 E.12761
G1 X138.784 Y125.103 E.6137
G2 X138.334 Y125.706 I3.967 J3.435 E.09122
G1 X134.152 Y121.524 E.71699
G1 X133.1 Y121.524 E.12761
G1 X137.984 Y126.408 E.83743
G2 X137.754 Y127.23 I3.318 J1.371 E.10377
G1 X132.048 Y121.524 E.97847
G1 X130.995 Y121.523 E.12761
G1 X138.061 Y128.59 E1.21168
; WIPE_START
G1 X136.647 Y127.175 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X143.961 Y129.359 Z.8 F42000
G1 X145.646 Y129.862 Z.8
G1 Z.4
G1 E.8 F1800
G1 F3300
M204 S500
G1 X146.615 Y130.83 E.16609
G1 X146.615 Y131.882 E.12758
G1 X145.469 Y130.737 E.19649
G3 X144.959 Y131.279 I-4.451 J-3.673 E.09032
G1 X146.615 Y132.935 E.2839
G1 X146.615 Y133.987 E.12758
G1 X144.355 Y131.729 E.38736
G3 X143.648 Y132.072 I-1.772 J-2.749 E.09545
G1 X146.049 Y134.473 E.41167
G1 X144.997 Y134.473 E.12754
G1 X142.831 Y132.307 E.37147
G3 X141.838 Y132.366 I-.727 J-3.848 E.12095
G1 X143.945 Y134.474 E.36138
G1 X142.894 Y134.474 E.12754
G1 X140.507 Y132.088 E.40915
G3 X137.965 Y129.545 I1.516 J-4.059 E.44964
G1 X129.943 Y121.523 E1.37555
G1 X128.89 Y121.523 E.12761
G1 X141.842 Y134.474 E2.22083
G1 X140.79 Y134.474 E.12754
G1 X127.838 Y121.523 E2.22092
G1 X126.785 Y121.522 E.12761
G1 X139.738 Y134.475 E2.22101
G1 X138.686 Y134.475 E.12754
G1 X125.733 Y121.522 E2.2211
G1 X124.681 Y121.522 E.12761
G1 X137.634 Y134.475 E2.2212
G1 X136.582 Y134.476 E.12754
G1 X123.459 Y121.352 E2.25032
G3 X121.745 Y120.556 I1.97 J-6.483 E.2299
G1 X121.48 Y120.426 E.03576
G1 X135.53 Y134.476 E2.40923
G1 X134.478 Y134.476 E.12754
G1 X119.828 Y119.826 E2.51211
G2 X118.574 Y119.624 I-1.832 J7.376 E.15423
G1 X133.426 Y134.476 E2.54682
G1 X132.375 Y134.477 E.12754
G1 X117.488 Y119.59 E2.5527
G2 X116.526 Y119.68 I.26 J7.985 E.11726
G1 X131.323 Y134.477 E2.53734
G1 X130.271 Y134.477 E.12754
G1 X115.656 Y119.862 E2.50612
G2 X114.856 Y120.115 I2.406 J9.003 E.1017
G1 X129.219 Y134.477 E2.46283
G1 X128.167 Y134.478 E.12754
G1 X114.121 Y120.432 E2.40857
G2 X113.44 Y120.803 I4.072 J8.267 E.09405
G1 X127.115 Y134.478 E2.3449
G1 X126.063 Y134.478 E.12754
G1 X112.81 Y121.225 E2.27265
G2 X112.229 Y121.696 I5.829 J7.785 E.09072
G1 X125.011 Y134.479 E2.19193
G2 X124.016 Y134.536 I-.243 J4.479 E.12111
G1 X111.693 Y122.213 E2.1131
G2 X111.205 Y122.777 I7.1 J6.63 E.09047
G1 X123.171 Y134.742 E2.0518
G2 X122.431 Y135.055 I1.054 J3.527 E.09756
M73 P35 R12
G1 X110.764 Y123.388 E2.00059
G2 X110.374 Y124.05 I7.847 J5.077 E.09318
G1 X121.76 Y135.436 E1.95249
G3 X121.043 Y135.771 I-5.171 J-10.123 E.09598
G1 X110.035 Y124.763 E1.88766
G2 X109.758 Y125.538 I8.964 J3.642 E.09983
G1 X120.271 Y136.051 E1.80275
G3 X119.43 Y136.263 I-2.198 J-6.959 E.10517
G1 X109.546 Y126.379 E1.69487
G2 X109.416 Y127.301 I9.881 J1.862 E.11297
G1 X118.506 Y136.39 E1.55858
G3 X117.476 Y136.413 I-.717 J-9.144 E.12491
G1 X109.394 Y128.331 E1.38585
G2 X109.527 Y129.516 I8.724 J-.378 E.1447
G1 X116.293 Y136.282 E1.1602
G3 X114.837 Y135.878 I1.325 J-7.597 E.18357
G1 X109.932 Y130.973 E.84105
G2 X111.619 Y133.712 I7.965 J-3.016 E.39241
G1 X113.55 Y135.643 E.33109
; WIPE_START
G1 X112.136 Y134.229 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X119.696 Y133.185 Z.8 F42000
G1 X146.403 Y129.499 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.909781
G1 F2100
M204 S500
G2 X146.463 Y129.065 I-11.314 J-1.788 E.05888
; LINE_WIDTH: 0.891074
G1 X146.476 Y128.942 E.01623
; LINE_WIDTH: 0.86275
G1 X146.491 Y128.796 E.0186
; LINE_WIDTH: 0.827494
G1 X146.511 Y128.522 E.03319
; LINE_WIDTH: 0.788738
G1 X146.526 Y127.989 E.06102
G1 X146.51 Y127.461 E.06055
; LINE_WIDTH: 0.830803
G1 X146.489 Y127.18 E.03416
; LINE_WIDTH: 0.865503
G1 X146.476 Y127.056 E.01583
; LINE_WIDTH: 0.904532
G1 X146.46 Y126.911 E.0195
G1 X145.947 Y126.605 E.07961
; CHANGE_LAYER
; Z_HEIGHT: 0.96
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F2100
G1 X146.46 Y126.911 E-.61046
G1 X146.476 Y127.056 E-.14954
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
G3 Z.96 I-.196 J-1.692 P1  F42000
G1 X138.454 Y127.983 Z.96
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X138.464 Y127.688 E.04718
G3 X141.892 Y124.394 I3.594 J.309 E.82899
G1 X142.099 Y124.39 E.03299
G3 X138.452 Y128.103 I-.042 J3.607 E2.69042
M204 S10000
G1 X139.156 Y127.988 F42000
G1 F3215.099
M204 S6000
G1 X139.184 Y127.555 E.06928
G3 X141.924 Y125.093 I2.874 J.442 E.63714
G1 X142.09 Y125.09 E.02648
G3 X139.152 Y128.108 I-.033 J2.907 E2.16484
M204 S250
G1 X139.852 Y128.033 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.875 Y127.659 E.0597
G3 X141.957 Y125.792 I2.182 J.339 E.48344
G1 X142.082 Y125.79 E.01998
G3 X139.854 Y128.152 I-.025 J2.208 E1.63288
; WIPE_START
M204 S6000
G1 X139.875 Y127.659 E-.18747
G1 X139.927 Y127.418 E-.09378
G1 X140.011 Y127.172 E-.0988
G1 X140.199 Y126.807 E-.156
G1 X140.442 Y126.494 E-.15062
G1 X140.581 Y126.361 E-.07332
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.354 Y123.906 Z1.36 F42000
G1 X123.567 Y120.582 Z1.36
G1 Z.96
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.634 Y120.603 E.01129
G2 X124.742 Y120.76 I1.144 J-4.094 E.17924
G1 X146.765 Y120.76 E3.51654
G3 X147.383 Y121.377 I.023 J.594 E.1565
G1 X147.383 Y134.623 E2.1151
G3 X146.765 Y135.241 I-.594 J.023 E.15655
G1 X124.744 Y135.241 E3.51628
G2 X122.782 Y135.738 I.034 J4.251 E.32626
G3 X108.718 Y129.354 I-4.955 J-7.767 E2.92461
G3 X118.45 Y118.833 I9.092 J-1.351 E2.62419
G3 X122.782 Y120.263 I-.709 J9.43 E.73573
M73 P36 R12
G2 X123.197 Y120.455 I1.995 J-3.753 E.07295
G1 X123.453 Y120.543 E.04332
M204 S10000
G1 X123.789 Y119.919 F42000
G1 F3215.099
M204 S6000
G1 X123.823 Y119.929 E.00565
G2 X124.752 Y120.06 I.954 J-3.415 E.15035
G1 X146.776 Y120.06 E3.5166
G3 X148.082 Y121.367 I.014 J1.293 E.32867
G1 X148.082 Y134.634 E2.11843
G3 X146.776 Y135.94 I-1.293 J.014 E.3287
G1 X124.753 Y135.94 E3.51641
G2 X123.112 Y136.355 I.024 J3.546 E.27296
G3 X118.499 Y118.135 I-5.298 J-8.353 E5.96398
G3 X123.112 Y119.645 I-.745 J10.076 E.78277
G2 X123.458 Y119.806 I1.665 J-3.131 E.06087
G1 X123.675 Y119.88 E.03671
M204 S250
G1 X124.011 Y119.255 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X124.763 Y119.36 I.765 J-2.737 E.12148
G1 X146.786 Y119.36 E3.51663
G3 X148.782 Y121.356 I.004 J1.992 E.5009
G1 X148.782 Y134.644 E2.12172
G3 X146.786 Y136.64 I-1.993 J.004 E.50092
G1 X124.763 Y136.64 E3.51652
G2 X123.442 Y136.973 I.013 J2.842 E.21965
G3 X118.548 Y117.436 I-5.629 J-8.971 E6.37753
G3 X123.442 Y119.028 I-.781 J10.725 E.82984
G2 X123.896 Y119.221 I1.334 J-2.509 E.07892
; WIPE_START
M204 S6000
G1 X124.312 Y119.323 E-.16262
G1 X124.763 Y119.36 E-.17181
G1 X125.882 Y119.36 E-.42557
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


G1 X138.246 Y127.26 F42000
G1 Z.96
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.823907
G1 F3197.249
M204 S6000
G1 X130.856 Y134.65 E1.67808
G1 X131.851 Y134.649 E.15984
G1 X137.903 Y128.598 E1.37422
G2 X138.095 Y129.401 I5.048 J-.784 E.13272
G1 X132.847 Y134.649 E1.19182
G1 X133.842 Y134.649 E.15984
M73 P36 R11
G1 X138.408 Y130.083 E1.03676
G2 X138.813 Y130.673 I3.364 J-1.878 E.11509
G1 X134.838 Y134.649 E.90277
G1 X135.833 Y134.649 E.15984
G1 X139.305 Y131.177 E.78836
G2 X139.884 Y131.593 I3.55 J-4.329 E.11458
G1 X136.828 Y134.648 E.69382
G1 X137.824 Y134.648 E.15984
G1 X140.551 Y131.921 E.61935
G2 X141.331 Y132.136 I1.325 J-3.275 E.13017
G1 X138.819 Y134.648 E.57034
G1 X139.815 Y134.648 E.15984
G1 X142.264 Y132.199 E.55606
G2 X143.513 Y131.945 I-.141 J-3.892 E.20563
G1 X140.495 Y134.962 E.68524
M204 S10000
G1 X145.473 Y134.961 F42000
G1 F3197.249
M204 S6000
G1 X146.788 Y133.646 E.29863
G1 X146.788 Y132.651 E.1598
G1 X144.792 Y134.646 E.45315
G1 X143.797 Y134.647 E.15984
G1 X146.788 Y131.655 E.67919
G1 X146.788 Y130.66 E.1598
G1 X142.801 Y134.647 E.90524
G1 X141.806 Y134.647 E.15984
G1 X146.788 Y129.665 E1.13129
G1 X146.788 Y128.67 E.1598
G1 X146.005 Y129.453 E.17776
G2 X146.258 Y128.204 I-3.813 J-1.424 E.20543
G1 X146.788 Y127.675 E.12021
G1 X146.788 Y126.679 E.1598
G1 X146.194 Y127.273 E.13474
G2 X145.983 Y126.489 I-5.077 J.95 E.13048
G1 X146.788 Y125.684 E.18276
G1 X146.788 Y124.689 E.1598
G1 X145.651 Y125.825 E.25805
G2 X145.237 Y125.245 I-2.637 J1.446 E.11482
G1 X146.788 Y123.694 E.35223
G1 X146.788 Y122.698 E.1598
G1 X144.728 Y124.758 E.46776
G2 X144.14 Y124.351 I-2.151 J2.48 E.11508
G1 X146.788 Y121.703 E.60134
G2 X146.783 Y121.36 I-1.668 J-.148 E.05528
G1 X146.141 Y121.355 E.10302
G1 X143.457 Y124.038 E.60943
G1 X143.359 Y124 E.01696
G2 X142.661 Y123.839 I-1.231 J3.755 E.11511
G1 X145.146 Y121.354 E.56425
G1 X144.151 Y121.354 E.15976
G1 X141.324 Y124.182 E.64207
; WIPE_START
G1 X142.738 Y122.767 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.134 Y127.949 Z1.36 F42000
G1 X129.545 Y134.965 Z1.36
G1 Z.96
G1 E.8 F1800
G1 F3197.249
M204 S6000
G1 X143.156 Y121.354 E3.09077
G1 X142.161 Y121.353 E.15976
G1 X128.865 Y134.65 E3.01936
G1 X127.869 Y134.65 E.15984
G1 X141.166 Y121.353 E3.01947
G1 X140.171 Y121.353 E.15976
M73 P37 R11
G1 X126.874 Y134.651 E3.01959
G1 X125.878 Y134.651 E.15984
G1 X139.177 Y121.353 E3.0197
G1 X138.182 Y121.352 E.15976
G1 X124.883 Y134.651 E3.01982
G2 X123.791 Y134.748 I-.152 J4.502 E.17644
G1 X137.187 Y121.352 E3.04183
G1 X136.192 Y121.352 E.15976
G1 X122.105 Y135.439 E3.19882
G3 X120.336 Y136.212 I-4.392 J-7.635 E.31054
G1 X135.197 Y121.352 E3.37447
G1 X134.202 Y121.351 E.15976
G1 X119.052 Y136.501 E3.44003
G3 X117.967 Y136.591 I-1.303 J-9.064 E.17505
G1 X133.207 Y121.351 E3.46065
G1 X132.212 Y121.351 E.15976
G1 X117.008 Y136.554 E3.45231
G3 X116.14 Y136.427 I.822 J-8.649 E.14095
G1 X131.217 Y121.351 E3.42353
G1 X130.222 Y121.35 E.15976
G1 X115.34 Y136.232 E3.37931
G3 X114.605 Y135.972 I1.84 J-6.36 E.12525
G1 X129.227 Y121.35 E3.32024
G1 X128.232 Y121.35 E.15976
G1 X113.918 Y135.664 E3.25031
G3 X113.283 Y135.303 I2.754 J-5.591 E.11728
G1 X127.237 Y121.35 E3.16853
G1 X126.242 Y121.349 E.15976
G1 X112.689 Y134.902 E3.07752
G3 X112.139 Y134.457 I6.805 J-8.961 E.11363
G1 X125.247 Y121.349 E2.97642
G1 X124.503 Y121.349 E.11949
G1 X124.277 Y121.324 E.03651
G1 X111.63 Y133.971 E2.87172
G3 X111.159 Y133.447 I9.945 J-9.415 E.11317
G1 X123.443 Y121.163 E2.78939
G3 X122.72 Y120.89 I.941 J-3.591 E.12425
G1 X110.734 Y132.876 E2.72172
G3 X110.35 Y132.266 I4.831 J-3.469 E.11594
G1 X122.072 Y120.543 E2.66187
G2 X121.418 Y120.202 I-3.166 J5.284 E.11855
G1 X110.011 Y131.609 E2.59025
G3 X109.722 Y130.903 I5.733 J-2.757 E.1226
G1 X120.71 Y119.915 E2.49518
G2 X119.951 Y119.678 I-2.352 J6.217 E.1277
G1 X109.487 Y130.142 E2.37607
G3 X109.316 Y129.318 I6.721 J-1.824 E.13525
G1 X119.123 Y119.511 E2.22698
G2 X118.22 Y119.419 I-1.332 J8.651 E.14592
G1 X109.226 Y128.413 E2.04223
G3 X109.237 Y127.406 I8.922 J-.403 E.16171
G1 X117.214 Y119.43 E1.81136
G2 X116.059 Y119.589 I.614 J8.684 E.18739
G1 X109.393 Y126.256 E1.51377
G3 X109.82 Y124.834 I7.893 J1.595 E.23879
G1 X114.638 Y120.016 E1.09399
G2 X111.876 Y121.782 I3.199 J8.044 E.52959
G1 X110.07 Y123.589 E.41018
; CHANGE_LAYER
; Z_HEIGHT: 1.52
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3197.249
G1 X111.484 Y122.174 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 3/51
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z1.52 I-.372 J1.663 P1  F42000
G1 X138.457 Y128.217 Z1.52
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X138.452 Y128.093 E.01975
G3 X141.888 Y124.394 I3.606 J-.096 E.89291
G1 X142.088 Y124.39 E.03201
G3 X138.467 Y128.336 I-.031 J3.607 E2.65478
M204 S10000
G1 X139.167 Y128.219 F42000
G1 F3215.099
M204 S6000
G1 X139.15 Y128.074 E.02325
G3 X141.921 Y125.093 I2.906 J-.076 E.7197
G1 X142.081 Y125.09 E.02555
G3 X139.213 Y128.605 I-.024 J2.907 E2.08607
G1 X139.181 Y128.338 E.043
M204 S250
M73 P38 R11
G1 X139.86 Y128.137 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.849 Y128.055 E.01321
G3 X141.954 Y125.793 I2.207 J-.057 E.5465
G1 X142.073 Y125.79 E.01909
G3 X139.897 Y128.46 I-.017 J2.208 E1.58428
G1 X139.873 Y128.256 E.03277
; WIPE_START
M204 S6000
G1 X139.849 Y128.055 E-.07703
G1 X139.877 Y127.65 E-.15427
G1 X139.926 Y127.423 E-.08806
G1 X140.007 Y127.181 E-.09724
G1 X140.202 Y126.803 E-.16136
G1 X140.444 Y126.491 E-.1502
G1 X140.505 Y126.433 E-.03185
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.762 Y130.01 Z1.92 F42000
G1 X123.567 Y135.419 Z1.92
G1 Z1.52
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.195 Y135.546 E.06279
G2 X122.782 Y135.738 I1.583 J3.945 E.07276
G3 X108.655 Y128.83 I-4.955 J-7.766 E3.00862
G3 X118.456 Y118.834 I9.159 J-.822 E2.54052
G3 X122.782 Y120.262 I-.714 J9.428 E.73469
G2 X124.742 Y120.76 I1.996 J-3.753 E.32607
G1 X146.766 Y120.76 E3.5166
G3 X147.383 Y121.377 I.023 J.594 E.15642
G1 X147.383 Y134.623 E2.1151
G3 X146.766 Y135.241 I-.594 J.023 E.15648
G1 X124.744 Y135.241 E3.51631
G2 X123.682 Y135.384 I.034 J4.251 E.1716
M204 S10000
G1 X123.789 Y136.081 F42000
G1 F3215.099
M204 S6000
G1 X123.456 Y136.195 E.05616
G2 X123.112 Y136.356 I1.321 J3.291 E.06069
G3 X118.505 Y118.135 I-5.298 J-8.353 E5.96497
G3 X123.112 Y119.645 I-.751 J10.075 E.7817
G2 X124.753 Y120.06 I1.665 J-3.131 E.27285
G1 X146.776 Y120.06 E3.5166
G3 X148.082 Y121.367 I.013 J1.293 E.32862
G1 X148.082 Y134.634 E2.11843
G3 X146.776 Y135.94 I-1.293 J.014 E.32871
G1 X124.754 Y135.94 E3.51639
G2 X123.905 Y136.049 I.023 J3.546 E.13698
M204 S250
G1 X124.012 Y136.745 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X123.442 Y136.973 I.764 J2.737 E.09819
G3 X118.554 Y117.437 I-5.628 J-8.971 E6.3786
G3 X123.442 Y119.028 I-.787 J10.724 E.82871
G2 X124.763 Y119.36 I1.334 J-2.508 E.21963
G1 X146.786 Y119.36 E3.5166
G3 X148.782 Y121.356 I.003 J1.992 E.50087
G1 X148.782 Y134.644 E2.12173
G3 X146.786 Y136.64 I-1.993 J.004 E.50095
G1 X124.763 Y136.64 E3.51646
G2 X124.128 Y136.715 I.013 J2.841 E.10234
; WIPE_START
M204 S6000
G1 X123.718 Y136.844 E-.16341
G1 X123.442 Y136.973 E-.1157
G1 X122.765 Y137.358 E-.29605
G1 X122.328 Y137.573 E-.18485
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
G1 X113.396 Y135.738 F42000
G1 Z1.52
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.823897
G1 F3197.294
M204 S6000
G1 X111.682 Y134.024 E.38922
G3 X109.82 Y131.167 I6.013 J-5.953 E.5513
G1 X114.639 Y135.986 E1.09425
G2 X116.06 Y136.412 I2.758 J-6.619 E.23865
G1 X109.393 Y129.744 E1.51401
G3 X109.237 Y128.593 I8.865 J-1.787 E.18665
G1 X117.215 Y136.571 E1.81154
G2 X118.22 Y136.581 I.589 J-8.545 E.16153
G1 X109.227 Y127.587 E2.0422
G3 X109.316 Y126.681 I10.192 J.549 E.14619
G1 X119.124 Y136.489 E2.22704
G2 X119.952 Y136.322 I-1.698 J-10.546 E.13567
G1 X109.488 Y125.858 E2.37606
G3 X109.721 Y125.097 I8.899 J2.314 E.12795
G1 X120.711 Y136.086 E2.49534
G2 X121.418 Y135.798 I-3.909 J-10.622 E.12265
G1 X110.011 Y124.391 E2.59023
G3 X110.349 Y123.734 I9.671 J4.569 E.11865
G1 X122.073 Y135.457 E2.66199
G3 X122.721 Y135.11 I2.496 J3.882 E.11817
G1 X110.734 Y123.124 E2.72175
G3 X111.159 Y122.554 I12.062 J8.549 E.1142
G1 X123.443 Y134.838 E2.78935
G3 X124.272 Y134.671 I1.652 J6.075 E.13582
M73 P39 R11
G1 X111.63 Y122.029 E2.87059
G3 X112.139 Y121.543 I4.392 J4.09 E.11309
G1 X125.247 Y134.651 E2.97642
G1 X126.242 Y134.651 E.15975
G1 X112.69 Y121.098 E3.07742
G3 X113.284 Y120.697 I3.805 J4.993 E.11515
G1 X127.237 Y134.651 E3.16847
G1 X128.232 Y134.65 E.15976
G1 X113.918 Y120.336 E3.25028
G3 X114.606 Y120.029 I5.762 J11.936 E.12093
G1 X129.227 Y134.65 E3.32016
G1 X130.222 Y134.65 E.15975
G1 X115.34 Y119.768 E3.37921
G3 X116.141 Y119.573 I1.953 J6.275 E.13234
G1 X131.217 Y134.65 E3.42342
G1 X132.212 Y134.649 E.15976
G1 X117.009 Y119.446 E3.45228
G3 X117.967 Y119.409 I.905 J11.099 E.15406
G1 X133.207 Y134.649 E3.46056
G1 X134.202 Y134.649 E.15975
G1 X119.052 Y119.499 E3.44003
G3 X120.337 Y119.788 I-1.402 J9.23 E.21151
G1 X135.197 Y134.649 E3.37437
G1 X136.192 Y134.648 E.15975
G1 X122.106 Y120.562 E3.19855
G2 X123.793 Y121.254 I2.75 J-4.304 E.29434
G1 X137.187 Y134.648 E3.04141
G1 X138.182 Y134.648 E.15975
G1 X124.883 Y121.349 E3.01986
G1 X125.878 Y121.349 E.15984
G1 X139.177 Y134.648 E3.01975
G1 X140.172 Y134.647 E.15975
G1 X126.874 Y121.349 E3.01963
G1 X127.869 Y121.35 E.15984
G1 X141.167 Y134.647 E3.01951
G1 X142.162 Y134.647 E.15976
G1 X128.865 Y121.35 E3.0194
G1 X129.86 Y121.35 E.15984
G1 X143.471 Y134.962 E3.09077
M204 S10000
G1 X141.321 Y131.816 F42000
G1 F3197.294
M204 S6000
G1 X144.152 Y134.646 E.64281
G1 X145.147 Y134.646 E.15975
G1 X142.657 Y132.157 E.56533
G2 X143.459 Y131.963 I-.662 J-4.514 E.13265
G1 X146.142 Y134.646 E.60912
G1 X146.783 Y134.641 E.10299
G2 X146.788 Y134.297 I-1.69 J-.196 E.05533
G1 X144.141 Y131.65 E.60106
G2 X144.732 Y131.246 I-2.403 J-4.159 E.1151
G1 X146.788 Y133.302 E.46671
G1 X146.788 Y132.307 E.15979
G1 X145.236 Y130.754 E.35244
G2 X145.655 Y130.179 I-2.816 J-2.494 E.11454
G1 X146.788 Y131.311 E.25715
G1 X146.788 Y130.316 E.15979
G1 X145.978 Y129.507 E.18383
G2 X146.2 Y128.733 I-4.76 J-1.779 E.12938
G1 X146.788 Y129.321 E.13358
G1 X146.788 Y128.326 E.15979
G1 X146.259 Y127.797 E.12015
G2 X145.987 Y126.529 I-3.507 J.09 E.20929
G1 X147.103 Y127.645 E.25342
M204 S10000
G1 X147.103 Y122.669 F42000
M73 P40 R11
G1 F3197.294
M204 S6000
G1 X145.788 Y121.354 E.2986
G1 X144.792 Y121.354 E.15984
G1 X146.788 Y123.35 E.45313
G1 X146.788 Y124.345 E.15979
G1 X143.797 Y121.354 E.67918
G1 X142.801 Y121.354 E.15984
G1 X146.788 Y125.34 E.90522
G1 X146.788 Y126.335 E.15979
G1 X141.806 Y121.353 E1.13127
G1 X140.81 Y121.353 E.15984
G1 X143.521 Y124.063 E.61543
G2 X142.266 Y123.804 I-1.413 J3.673 E.20658
G1 X139.815 Y121.353 E.55664
G1 X138.819 Y121.353 E.15984
G1 X141.327 Y123.86 E.56939
G2 X140.55 Y124.079 I1.133 J5.515 E.12966
G1 X137.824 Y121.352 E.61908
G1 X136.828 Y121.352 E.15984
G1 X139.884 Y124.408 E.6939
G2 X139.309 Y124.828 I1.601 J2.799 E.1146
G1 X135.833 Y121.352 E.78926
G1 X134.837 Y121.351 E.15984
G1 X138.806 Y125.334 E.90272
G2 X138.411 Y125.921 I2.348 J2.006 E.11385
G1 X133.842 Y121.351 E1.03758
G1 X132.847 Y121.351 E.15984
G1 X138.099 Y126.604 E1.19274
G2 X137.899 Y127.398 I4.612 J1.585 E.13178
G1 X131.851 Y121.351 E1.3733
G1 X130.856 Y121.35 E.15984
G1 X138.243 Y128.737 E1.6774
; CHANGE_LAYER
; Z_HEIGHT: 2.08
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3197.294
G1 X136.828 Y127.323 E-.76
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
G3 Z2.08 I-.984 J1.391 P1  F42000
G1 X138.489 Y128.499 Z2.08
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X138.467 Y128.339 E.02576
G3 X141.716 Y124.405 I3.591 J-.343 E.90478
G1 X142.053 Y124.389 E.05386
G3 X138.531 Y128.75 I.006 J3.607 E2.59403
G1 X138.509 Y128.617 E.02153
M204 S10000
G1 X139.18 Y128.393 F42000
G1 F3215.099
M204 S6000
G1 X139.163 Y128.275 E.01902
G3 X141.779 Y125.103 I2.894 J-.278 E.72914
G1 X142.056 Y125.09 E.0443
G3 X139.214 Y128.605 I.002 J2.908 E2.09048
G1 X139.199 Y128.512 E.01512
M204 S250
G1 X139.871 Y128.287 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.859 Y128.211 E.01226
G3 X141.842 Y125.801 I2.198 J-.213 E.55351
G1 X142.059 Y125.79 E.03471
G3 X139.898 Y128.46 I-.002 J2.208 E1.58693
G1 X139.889 Y128.406 E.00874
; WIPE_START
M204 S6000
G1 X139.859 Y128.211 E-.07478
G1 X139.859 Y127.795 E-.15816
G1 X139.881 Y127.631 E-.06282
G1 X139.96 Y127.311 E-.12553
G1 X140.14 Y126.904 E-.169
G1 X140.347 Y126.603 E-.13868
G1 X140.404 Y126.545 E-.03105
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.652 Y130.103 Z2.48 F42000
G1 X123.567 Y135.419 Z2.48
G1 Z2.08
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.193 Y135.547 E.06309
G2 X122.781 Y135.738 I1.584 J3.944 E.07258
G3 X108.656 Y128.834 I-4.954 J-7.766 E3.00788
G3 X118.462 Y118.834 I9.159 J-.827 E2.54223
G3 X122.782 Y120.262 I-.721 J9.427 E.7336
G2 X124.741 Y120.76 I1.996 J-3.752 E.32595
G1 X146.766 Y120.76 E3.51675
G3 X147.383 Y121.377 I.023 J.594 E.15642
G1 X147.383 Y134.623 E2.1151
G3 X146.765 Y135.241 I-.594 J.023 E.15655
G1 X124.744 Y135.241 E3.51627
G2 X123.682 Y135.384 I.034 J4.25 E.17156
M204 S10000
G1 X123.789 Y136.081 F42000
G1 F3215.099
M204 S6000
G1 X123.455 Y136.196 E.05646
G2 X123.112 Y136.356 I1.322 J3.29 E.06049
G3 X118.512 Y118.136 I-5.298 J-8.353 E5.966
G3 X123.112 Y119.645 I-.757 J10.074 E.78058
G2 X124.752 Y120.06 I1.665 J-3.13 E.2728
G1 X146.776 Y120.06 E3.51668
G3 X148.082 Y121.366 I.014 J1.293 E.32862
G1 X148.082 Y134.634 E2.11843
G3 X146.776 Y135.94 I-1.293 J.014 E.32873
G1 X124.754 Y135.94 E3.51637
G2 X123.905 Y136.049 I.023 J3.545 E.13693
M204 S250
G1 X124.012 Y136.745 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X123.442 Y136.973 I.764 J2.737 E.09829
G3 X118.561 Y117.438 I-5.628 J-8.971 E6.37967
G3 X123.442 Y119.027 I-.794 J10.723 E.82757
G2 X124.763 Y119.36 I1.334 J-2.508 E.21964
G1 X146.786 Y119.36 E3.51662
G3 X148.782 Y121.356 I.004 J1.992 E.50088
G1 X148.782 Y134.644 E2.12173
G3 X146.786 Y136.64 I-1.993 J.004 E.50094
G1 X124.763 Y136.64 E3.51648
G2 X124.128 Y136.715 I.013 J2.841 E.10228
; WIPE_START
M204 S6000
G1 X123.716 Y136.845 E-.16408
G1 X123.442 Y136.973 E-.11526
G1 X122.767 Y137.357 E-.29491
G1 X122.329 Y137.573 E-.18575
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


G1 X112.209 Y134.52 F42000
G1 Z2.08
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G3 X110.42 Y132.384 I6.461 J-7.227 E.44648
G1 X122.192 Y120.612 E2.6583
G2 X119.599 Y119.599 I-4.761 J8.369 E.44606
G1 X134.649 Y134.649 E3.39839
G1 X134.547 Y134.649 E.01622
G1 X138.687 Y130.509 E.93478
G3 X138.693 Y125.497 I3.356 J-2.502 E.8581
G1 X134.547 Y121.351 E.93608
G1 X134.649 Y121.351 E.0162
G1 X119.597 Y136.403 E3.39884
G2 X122.193 Y135.389 I-2.19 J-9.435 E.4465
G1 X110.42 Y123.616 E2.65849
G3 X112.209 Y121.48 I8.418 J5.234 E.44645
M204 S10000
G1 X143.319 Y123.881 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
M73 P41 R11
G1 X144.027 Y124.167 E.12197
G1 X144.777 Y124.655 E.14288
G1 X145.439 Y125.327 E.15055
G1 X145.861 Y125.97 E.12277
G1 X146.086 Y126.464 E.0868
; LINE_WIDTH: 0.844801
G1 F3105.06
G1 X146.131 Y126.521 E.01193
; LINE_WIDTH: 0.894408
G1 F2906.111
G1 X146.175 Y126.578 E.01274
; LINE_WIDTH: 0.944015
G1 F2731.12
G1 X146.219 Y126.635 E.01356
; LINE_WIDTH: 0.993622
G1 F2576.007
G1 X146.263 Y126.692 E.01438
; LINE_WIDTH: 1.04323
G1 F2437.566
G1 X146.308 Y126.749 E.01519
; LINE_WIDTH: 1.09284
G1 F2313.246
G1 X146.352 Y126.806 E.01601
; LINE_WIDTH: 1.14244
G1 F2200.992
G1 X146.396 Y126.863 E.01682
; LINE_WIDTH: 1.19119
G1 F2100.816
G1 X146.429 Y126.897 E.01155
; LINE_WIDTH: 1.23907
G1 F2010.908
G1 X146.461 Y126.931 E.01207
; LINE_WIDTH: 1.2384
G1 F2012.112
G1 X146.486 Y126.874 E.01598
; LINE_WIDTH: 1.18918
G1 F2104.764
G1 X146.511 Y126.816 E.01528
; LINE_WIDTH: 1.13996
G1 F2206.361
G1 X146.535 Y126.759 E.01458
; LINE_WIDTH: 1.09073
G1 F2318.263
G1 X146.56 Y126.701 E.01387
; LINE_WIDTH: 1.04151
G1 F2442.122
G1 X146.584 Y126.643 E.01317
; LINE_WIDTH: 0.992283
G1 F2579.963
G1 X146.609 Y126.586 E.01247
; LINE_WIDTH: 0.943058
G1 F2734.295
G1 X146.634 Y126.528 E.01176
; LINE_WIDTH: 0.893834
G1 F2908.267
G1 X146.658 Y126.47 E.01106
; LINE_WIDTH: 0.820166
G1 F3214.337
G1 X146.683 Y126.413 E.01001
G1 X146.683 Y121.46 E.79109
G1 X146.251 Y121.46 E.06902
G1 X146.108 Y121.629 E.03538
G1 X143.899 Y123.334 E.44567
G1 X143.402 Y123.795 E.10822
M204 S10000
G1 X144.728 Y123.682 F42000
; LINE_WIDTH: 0.984747
G1 F2602.45
M204 S6000
G1 X145.211 Y124.005 E.11454
G1 X145.901 Y124.68 E.19043
G1 X145.901 Y122.777 E.37532
G1 X144.823 Y123.609 E.2686
M204 S10000
G1 X146.51 Y128.538 F42000
; LINE_WIDTH: 1.15332
G1 F2177.827
M204 S6000
G1 X146.522 Y127.771 E.18083
; LINE_WIDTH: 1.1611
G1 F2161.542
G1 X146.505 Y127.531 E.05712
; LINE_WIDTH: 1.20187
G1 F2080.078
G1 X146.488 Y127.291 E.05936
; LINE_WIDTH: 1.24263
G1 F2004.532
G1 X146.47 Y127.051 E.06159
M204 S10000
G1 X144.729 Y132.325 F42000
; LINE_WIDTH: 0.993937
G1 F2575.078
M204 S6000
G1 X145.896 Y133.281 E.30084
G1 X145.896 Y131.341 E.38671
G1 X145.407 Y131.839 E.13904
G1 X144.826 Y132.255 E.14245
M204 S10000
G1 X143.307 Y132.108 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X143.753 Y132.543 E.09946
G1 X146.19 Y134.539 E.50309
G1 X146.683 Y134.533 E.07866
G1 X146.683 Y129.299 E.83571
; LINE_WIDTH: 0.843619
G1 F3110.132
G1 X146.659 Y129.193 E.01798
; LINE_WIDTH: 0.890863
G1 F2919.475
G1 X146.636 Y129.087 E.01915
; LINE_WIDTH: 0.938108
G1 F2750.844
G1 X146.612 Y128.98 E.02033
; LINE_WIDTH: 0.985352
G1 F2600.63
G1 X146.588 Y128.874 E.0215
; LINE_WIDTH: 1.0326
G1 F2465.972
G1 X146.565 Y128.768 E.02267
; LINE_WIDTH: 1.07984
G1 F2344.572
G1 X146.541 Y128.661 E.02385
; LINE_WIDTH: 1.12708
G1 F2234.564
G1 X146.517 Y128.555 E.02502
; LINE_WIDTH: 1.15831
G1 F2167.348
G1 X146.51 Y128.538 E.00452
; LINE_WIDTH: 1.14121
G1 F2203.654
G1 X146.463 Y128.639 E.02599
; LINE_WIDTH: 1.09179
G1 F2315.734
G1 X146.417 Y128.74 E.02474
; LINE_WIDTH: 1.04237
G1 F2439.825
G1 X146.37 Y128.842 E.02348
; LINE_WIDTH: 0.992957
G1 F2577.969
G1 X146.324 Y128.943 E.02222
; LINE_WIDTH: 0.94354
G1 F2732.695
G1 X146.277 Y129.045 E.02096
; LINE_WIDTH: 0.894123
G1 F2907.181
G1 X146.231 Y129.146 E.0197
; LINE_WIDTH: 0.820651
G1 F3212.113
G2 X145.895 Y129.965 I8.668 J4.036 E.14151
G1 X145.441 Y130.672 E.13421
G1 X144.846 Y131.288 E.13688
G1 X144.132 Y131.778 E.13846
G1 X143.657 Y132.003 E.08401
G1 X143.422 Y132.073 E.0392
; CHANGE_LAYER
; Z_HEIGHT: 2.64
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3212.113
G1 X143.657 Y132.003 E-.09319
G1 X144.132 Y131.778 E-.19975
G1 X144.846 Y131.288 E-.32921
G1 X145.098 Y131.027 E-.13785
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 5/51
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z2.64 I.152 J-1.697 P1  F42000
G1 X144.153 Y130.942 Z2.64
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X145.519 Y132.524 I6.348 J-4.099 E.33481
G1 X147.383 Y134.049 E.38443
G3 X147.367 Y134.782 I-3.697 J.287 E.11723
G1 X147.301 Y134.949 E.02872
G1 X147.169 Y135.103 E.03237
G1 X147.029 Y135.19 E.02639
G1 X146.861 Y135.236 E.02779
G3 X146.766 Y135.241 I-.089 J-.815 E.01516
G1 X124.744 Y135.241 E3.51635
G2 X122.781 Y135.739 I.033 J4.25 E.32649
G3 X108.719 Y126.643 I-4.955 J-7.759 E3.35847
G3 X118.468 Y118.835 I9.099 J1.37 E2.19232
G3 X122.782 Y120.262 I-.726 J9.425 E.73263
G2 X124.741 Y120.76 I1.996 J-3.752 E.32594
G1 X146.766 Y120.76 E3.51676
G3 X147.383 Y121.377 I.023 J.594 E.15641
G1 X147.383 Y122.018 E.10246
G1 X145.699 Y123.319 E.33967
G2 X144.813 Y124.185 I10.2 J11.334 E.19793
G2 X144.163 Y125.053 I5.821 J5.033 E.1733
G2 X139.27 Y130.292 I-2.086 J2.956 E1.65696
G2 X144.054 Y131.01 I2.794 J-2.318 E.84552
; WIPE_START
G1 X144.608 Y131.575 E-.30067
G1 X144.978 Y132 E-.21417
G1 X145.441 Y132.449 E-.24516
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.403 Y129.953 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X144.712 Y130.52 E.10321
G2 X145.985 Y132.001 I6.828 J-4.58 E.31252
G1 X148.082 Y133.717 E.4327
G3 X148.073 Y134.8 I-9.829 J.458 E.17293
G3 X146.776 Y135.94 I-1.284 J-.152 E.30206
G1 X124.754 Y135.94 E3.51644
G2 X123.111 Y136.356 I.023 J3.545 E.27313
G3 X118.518 Y118.137 I-5.297 J-8.353 E5.96658
G3 X123.112 Y119.645 I-.763 J10.072 E.77955
G2 X124.752 Y120.06 I1.665 J-3.13 E.27278
G1 X146.776 Y120.06 E3.51671
G3 X148.082 Y121.366 I.014 J1.293 E.32861
G1 X148.082 Y122.362 E.15896
G1 X146.157 Y123.85 E.38862
G2 X145.333 Y124.653 I9.551 J10.621 E.18375
G2 X144.336 Y126.178 I5.089 J4.415 E.29178
G2 X144.331 Y129.821 I-2.272 J1.819 E2.29107
G1 X144.346 Y129.847 E.00481
; WIPE_START
G1 X144.712 Y130.52 E-.29122
G1 X145.15 Y131.132 E-.28572
G1 X145.466 Y131.495 E-.18306
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.885 Y128.382 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.86 Y128.215 E.02687
G3 X141.845 Y125.8 I2.197 J-.217 E.55454
G1 X142.051 Y125.79 E.03298
G3 X139.907 Y128.5 I.006 J2.208 E1.58138
; WIPE_START
M204 S6000
G1 X139.86 Y128.215 E-.1095
G1 X139.859 Y127.793 E-.16047
G1 X139.957 Y127.318 E-.1843
G1 X140.144 Y126.898 E-.17488
G1 X140.339 Y126.614 E-.13086
; WIPE_END
G1 E-.04 F1800
M204 S10000
M73 P41 R10
G1 X147.731 Y128.313 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
G1 F3215.099
M204 S5000
G2 X148.146 Y129.46 I2.704 J-.329 E.19643
G2 X148.782 Y130.246 I4.27 J-2.807 E.16171
G1 X148.782 Y134.644 E.70231
G3 X146.786 Y136.64 I-1.993 J.003 E.50092
G1 X124.763 Y136.64 E3.5165
G2 X123.442 Y136.973 I.013 J2.841 E.21976
G3 X118.568 Y117.438 I-5.628 J-8.971 E6.38035
G3 X123.442 Y119.027 I-.8 J10.722 E.82647
G2 X124.763 Y119.36 I1.334 J-2.508 E.21963
G1 X146.786 Y119.36 E3.51666
G3 X148.782 Y121.356 I.004 J1.992 E.50086
G1 X148.782 Y125.754 E.70221
G2 X147.75 Y127.527 I2.43 J2.602 E.33229
G2 X147.72 Y128.193 I2.685 J.457 E.10679
; WIPE_START
M204 S6000
G1 X147.796 Y128.662 E-.18053
G1 X147.956 Y129.105 E-.17912
G1 X148.146 Y129.46 E-.15281
G1 X148.394 Y129.814 E-.16415
G1 X148.54 Y129.977 E-.08338
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


G1 X148.502 Y124.058 F42000
G1 Z2.64
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.874117
G1 F2984.322
M204 S2000
G1 X147.786 Y123.342 E.17419
G1 X147.185 Y123.807 E.13076
G1 X148.188 Y124.81 E.2439
G1 X148.188 Y125.519 E.12192
G2 X148.019 Y125.707 I.87 J.947 E.04362
G1 X146.732 Y124.42 E.31309
M73 P42 R10
G1 X146.281 Y124.631 E.08557
G1 X146.063 Y124.746 E.0424
G1 X146.028 Y124.783 E.00876
G1 X147.582 Y126.336 E.37793
G2 X147.256 Y127.077 I4.601 J2.467 E.13929
G1 X145.532 Y125.353 E.41933
G2 X145.106 Y125.993 I4.897 J3.719 E.13238
G1 X147.114 Y128.001 E.48849
G2 X147.43 Y129.384 I3.245 J-.015 E.24594
G1 X144.778 Y126.732 E.64521
G2 X144.691 Y127.036 I2.409 J.859 E.0545
G3 X144.861 Y127.88 I-3.054 J1.055 E.14865
G1 X148.188 Y131.207 E.80931
G1 X148.188 Y132.273 E.18342
G1 X144.74 Y128.826 E.83867
G1 X144.69 Y128.969 E.02602
G2 X145.665 Y130.817 I4.478 J-1.181 E.36253
G1 X148.438 Y133.591 E.67479
; WIPE_START
M204 S6000
G1 X147.024 Y132.176 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.55 Y131.94 Z3.04 F42000
G1 Z2.64
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X141.091 Y132.025 E.08495
M204 S10000
G1 X146.671 Y134.541 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G2 X146.633 Y134.339 I-.223 J-.062 E.03389
G1 X145.064 Y133.056 E.32355
G1 X144.48 Y132.492 E.12968
G3 X143.969 Y131.858 I71.025 J-57.794 E.13008
G1 X143.42 Y132.085 E.09488
G1 X142.44 Y132.292 E.15988
G1 X141.787 Y132.299 E.10432
G1 X142.237 Y132.712 E.0976
G1 X144.467 Y134.541 E.46042
G1 X146.551 Y134.541 E.33273
M204 S10000
G1 X143.712 Y132.856 F42000
; LINE_WIDTH: 1.04928
G1 F2421.69
M204 S6000
G1 X143.978 Y133.1 E.07645
; LINE_WIDTH: 1.01001
G1 F2528.573
G1 X144.244 Y133.343 E.07321
; LINE_WIDTH: 0.963644
G1 F2667.561
G2 X144.647 Y133.701 I3.881 J-3.971 E.10383
; WIPE_START
G1 X144.244 Y133.343 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.63 Y125.735 Z3.04 F42000
G1 X143.486 Y123.942 Z3.04
G1 Z2.64
G1 E.8 F1800
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X143.946 Y124.143 E.08022
G3 X145.991 Y122.21 I7.575 J5.96 E.45095
G1 X146.217 Y122.035 E.04565
G1 X146.117 Y121.648 E.06372
G1 X145.931 Y121.459 E.04239
G1 X144.546 Y121.459 E.22117
G1 X144.306 Y121.69 E.05316
G1 X142.144 Y123.361 E.43628
G1 X141.781 Y123.715 E.08102
G3 X143.37 Y123.91 I.302 J4.124 E.25731
M204 S10000
G1 X143.711 Y123.169 F42000
; LINE_WIDTH: 1.00974
G1 F2529.34
M204 S6000
G1 X143.908 Y122.988 E.05416
; LINE_WIDTH: 0.964217
G1 F2665.75
G1 X144.104 Y122.807 E.05139
; LINE_WIDTH: 0.922457
G1 F2804.507
G1 X144.426 Y122.535 E.07722
; LINE_WIDTH: 0.883897
G1 F2946.107
G3 X144.757 Y122.255 I4.81 J5.349 E.07554
M204 S10000
G1 X146.992 Y121.7 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.235083
G1 F3000
M204 S6000
G1 X146.972 Y121.582 E.00313
; LINE_WIDTH: 0.268454
G1 X146.952 Y121.465 E.00404
; LINE_WIDTH: 0.308583
G2 X146.872 Y121.217 I-.408 J-.005 E.0114
; LINE_WIDTH: 0.280452
G1 X146.859 Y121.202 E.00073
; LINE_WIDTH: 0.249068
G1 X146.76 Y121.107 E.00401
M204 S10000
G1 X112.209 Y121.48 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.42 Y123.616 I6.686 J7.418 E.44643
G1 X122.193 Y135.389 E2.6585
G3 X119.597 Y136.403 I-4.795 J-8.445 E.44651
G1 X134.649 Y121.351 E3.39887
G1 X134.547 Y121.351 E.01624
G1 X138.687 Y125.491 E.93479
G2 X138.689 Y130.507 I3.387 J2.506 E.85787
G1 X134.547 Y134.649 E.93535
G1 X134.649 Y134.649 E.01621
G1 X119.6 Y119.6 E3.3983
G3 X122.192 Y120.612 I-2.169 J9.384 E.44598
G1 X110.419 Y132.385 E2.65851
G2 X112.209 Y134.521 I8.333 J-5.164 E.44649
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.167 Y133.456 E-.56594
G1 X110.875 Y133.038 E-.19406
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 6/51
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z3.2 I.269 J1.682 P1  F42000
G1 X139.889 Y128.406 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.86 Y128.22 E.03006
G3 X141.847 Y125.8 I2.198 J-.22 E.55566
G1 X142.043 Y125.79 E.03129
G3 X139.912 Y128.523 I.015 J2.209 E1.58004
; WIPE_START
M204 S6000
G1 X139.86 Y128.22 E-.11708
G1 X139.859 Y127.795 E-.16142
G1 X139.938 Y127.381 E-.16023
G1 X140.017 Y127.155 E-.09085
G1 X140.119 Y126.942 E-.08975
G1 X140.325 Y126.634 E-.14067
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.845 Y131.524 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G2 X143.787 Y132.517 I6.887 J-5.587 E.21878
G1 X147.113 Y135.241 E.6864
G1 X124.744 Y135.241 E3.57174
G2 X122.781 Y135.739 I.033 J4.249 E.32653
G3 X108.718 Y126.645 I-4.954 J-7.759 E3.3581
G3 X118.475 Y118.835 I9.101 J1.37 E2.19355
G3 X122.781 Y120.262 I-.73 J9.418 E.73159
G2 X124.74 Y120.76 I1.996 J-3.752 E.3258
G1 X146.837 Y120.76 E3.52838
G1 X146.934 Y121.045 E.04804
G1 X144.125 Y123.201 E.5655
G2 X142.848 Y124.473 I6.303 J7.608 E.28806
G2 X142.728 Y131.548 I-.786 J3.525 E2.04514
M204 S10000
G1 X143.118 Y130.711 F42000
G1 F3215.099
M204 S6000
G2 X144.254 Y131.994 I5.549 J-3.764 E.27445
G1 X146.744 Y134.034 E.51403
G1 X148.082 Y132.801 E.29062
G1 X148.082 Y134.634 E.29269
G3 X146.776 Y135.94 I-1.293 J.014 E.32867
G1 X124.754 Y135.94 E3.51643
G2 X123.111 Y136.356 I.023 J3.545 E.27316
G3 X117.926 Y118.111 I-5.297 J-8.354 E5.87249
G3 X123.111 Y119.645 I-.16 J10.078 E.87415
G2 X124.751 Y120.06 I1.665 J-3.129 E.27271
G1 X146.776 Y120.06 E3.51678
G3 X148.082 Y121.367 I.013 J1.294 E.32862
G1 X148.082 Y123.111 E.27849
G1 X146.914 Y121.942 E.26386
G1 X144.561 Y123.749 E.47363
G2 X143.415 Y124.885 I5.955 J7.153 E.25809
G1 X143.11 Y125.287 E.08043
G2 X143.005 Y130.752 I-1.048 J2.713 E1.7837
; WIPE_START
G1 X143.354 Y131.041 E-.17217
G1 X143.752 Y131.506 E-.23259
G1 X144.254 Y131.994 E-.26609
G1 X144.435 Y132.143 E-.08916
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.019 Y128.376 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X146.707 Y129.86 I2.941 J-.463 E.26453
G2 X148.782 Y131.518 I5.638 J-4.925 E.42646
G1 X148.782 Y134.644 E.49909
M73 P43 R10
G3 X146.786 Y136.64 I-1.993 J.003 E.5009
G1 X124.763 Y136.64 E3.51652
G2 X123.441 Y136.973 I.013 J2.84 E.21981
G3 X117.95 Y117.412 I-5.631 J-8.971 E6.28356
G3 X123.441 Y119.027 I-.173 J10.73 E.92515
G2 X124.762 Y119.36 I1.334 J-2.507 E.21965
G1 X146.786 Y119.36 E3.51664
G3 X148.782 Y121.357 I.002 J1.994 E.50086
G1 X148.782 Y124.482 E.49911
G2 X146.768 Y126.067 I3.504 J6.527 E.41133
G2 X145.983 Y127.93 I2.307 J2.069 E.32883
G2 X146.003 Y128.257 I2.977 J-.017 E.05236
; WIPE_START
M204 S6000
G1 X146.071 Y128.661 E-.15556
G1 X146.187 Y128.998 E-.13554
G1 X146.426 Y129.465 E-.19937
G1 X146.707 Y129.86 E-.18403
G1 X146.855 Y130.029 E-.0855
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


G1 X147.846 Y131.257 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828127
G1 F3178.19
M204 S2000
G1 X146.246 Y132.857 E.36547
G1 X145.696 Y132.406 E.11492
G1 X147.054 Y131.048 E.31035
G3 X146.536 Y130.565 I2.605 J-3.314 E.11456
G1 X145.145 Y131.956 E.31771
G1 X144.599 Y131.501 E.11483
G1 X146.084 Y130.016 E.33916
G3 X145.71 Y129.389 I4.157 J-2.904 E.11806
G1 X144.099 Y130.999 E.36796
G3 X143.655 Y130.442 I5.232 J-4.616 E.11514
G1 X145.459 Y128.639 E.41191
G3 X145.406 Y127.69 I3.069 J-.645 E.15412
G1 X144.853 Y128.243 E.12643
G2 X144.777 Y127.317 I-3.038 J-.218 E.15059
G1 X148.113 Y123.982 E.76188
G1 X147.612 Y123.482 E.11436
G1 X144.49 Y126.604 E.71322
G2 X144.059 Y126.033 I-2.939 J1.772 E.11567
G1 X147.111 Y122.981 E.69728
G1 X146.862 Y122.732 E.05689
G1 X144.932 Y124.214 E.3931
G2 X144.348 Y124.743 I12.884 J14.807 E.12722
G1 X143.279 Y125.813 E.24438
; WIPE_START
M204 S6000
G1 X144.348 Y124.743 E-.5749
G1 X144.709 Y124.416 E-.1851
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.88 Y123.076 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.25544
G1 F1981.925
M204 S6000
G1 X143.1 Y122.889 E.07462
; LINE_WIDTH: 1.21688
G1 F2051.596
G3 X143.359 Y122.671 I4.925 J5.584 E.08462
G1 X144.562 Y121.742 E.38062
M204 S10000
G1 X142.88 Y123.076 F42000
; LINE_WIDTH: 1.24363
G1 F2002.749
M204 S6000
G1 X142.836 Y123.078 E.01127
; LINE_WIDTH: 1.1939
G1 F2095.503
G1 X142.792 Y123.081 E.01077
; LINE_WIDTH: 1.14418
G1 F2197.267
G1 X142.748 Y123.083 E.01027
; LINE_WIDTH: 1.09445
G1 F2309.418
G1 X142.705 Y123.086 E.00978
; LINE_WIDTH: 1.04472
G1 F2433.634
G1 X142.661 Y123.088 E.00928
; LINE_WIDTH: 0.994992
G1 F2571.972
G1 X142.617 Y123.091 E.00878
; LINE_WIDTH: 0.945264
G1 F2726.986
G1 X142.573 Y123.093 E.00828
; LINE_WIDTH: 0.895536
G1 F2901.883
G1 X142.529 Y123.096 E.00778
; LINE_WIDTH: 0.845807
G1 F3100.752
G1 X142.485 Y123.098 E.00728
; LINE_WIDTH: 0.796079
G1 F3328.884
G1 X142.441 Y123.101 E.00678
; LINE_WIDTH: 0.734396
G1 F3663.186
G1 X142.397 Y123.103 E.00616
G2 X141.667 Y123.769 I5.295 J6.543 E.13853
G1 X142.057 Y123.732 E.05493
G1 X142.584 Y123.779 E.0741
G1 X142.806 Y123.541 E.04559
; LINE_WIDTH: 0.746351
G1 F3593.25
G1 X142.811 Y123.509 E.00456
; LINE_WIDTH: 0.796079
G1 F3328.884
G1 X142.816 Y123.478 E.00492
; LINE_WIDTH: 0.845807
G1 F3100.752
G1 X142.821 Y123.446 E.00528
; LINE_WIDTH: 0.895536
G1 F2901.883
G1 X142.826 Y123.415 E.00565
; LINE_WIDTH: 0.945264
G1 F2726.986
G1 X142.831 Y123.383 E.00601
; LINE_WIDTH: 0.994992
G1 F2571.972
G1 X142.836 Y123.352 E.00637
; LINE_WIDTH: 1.04472
G1 F2433.634
G1 X142.841 Y123.32 E.00673
; LINE_WIDTH: 1.09445
G1 F2309.418
G1 X142.846 Y123.289 E.0071
; LINE_WIDTH: 1.14418
G1 F2197.267
G1 X142.851 Y123.257 E.00746
; LINE_WIDTH: 1.1939
G1 F2095.503
G1 X142.856 Y123.226 E.00782
; LINE_WIDTH: 1.24363
G1 F2002.749
G1 X142.861 Y123.194 E.00818
; WIPE_START
G1 X142.856 Y123.226 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.293 Y121.826 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.576318
G1 F3000
M204 S6000
G1 X147.513 Y121.309 E.05856
; LINE_WIDTH: 0.541721
G1 X147.521 Y121.266 E.00412
; LINE_WIDTH: 0.515851
G1 X147.529 Y121.224 E.00387
; LINE_WIDTH: 0.47883
G2 X147.458 Y120.968 I-.673 J.048 E.02194
; LINE_WIDTH: 0.450907
G1 X147.417 Y120.884 E.00704
; LINE_WIDTH: 0.422655
G1 X147.374 Y120.806 E.00615
; LINE_WIDTH: 0.391657
G1 X147.34 Y120.752 E.00393
; LINE_WIDTH: 0.354121
G1 X147.15 Y120.477 E.01787
; WIPE_START
G1 X147.34 Y120.752 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.867 Y127.973 Z3.6 F42000
G1 X143.1 Y133.132 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.25525
G1 F1982.245
M204 S6000
G1 X144.452 Y134.247 E.4539
M204 S10000
G1 X143.1 Y133.132 F42000
; LINE_WIDTH: 1.24003
G1 F2009.185
M204 S6000
G1 X143.093 Y133.089 E.01126
; LINE_WIDTH: 1.19011
G1 F2102.938
G1 X143.085 Y133.045 E.01076
; LINE_WIDTH: 1.14018
G1 F2205.869
G1 X143.078 Y133.002 E.01025
; LINE_WIDTH: 1.09026
G1 F2319.394
G1 X143.071 Y132.958 E.00975
; LINE_WIDTH: 1.04033
G1 F2445.239
G1 X143.064 Y132.915 E.00925
; LINE_WIDTH: 0.990407
G1 F2585.524
G1 X143.056 Y132.871 E.00875
; LINE_WIDTH: 0.940482
G1 F2742.884
G1 X143.049 Y132.828 E.00825
; LINE_WIDTH: 0.890556
G1 F2920.64
G1 X143.042 Y132.785 E.00774
; LINE_WIDTH: 0.840631
G1 F3123.032
G1 X143.035 Y132.741 E.00724
; LINE_WIDTH: 0.790705
G1 F3355.564
G1 X143.028 Y132.698 E.00674
; LINE_WIDTH: 0.737344
G1 F3645.692
G1 X143.02 Y132.654 E.0062
G1 X142.599 Y132.236 E.08362
G1 X141.789 Y132.263 E.11402
G1 X141.686 Y132.252 E.01466
G2 X142.617 Y133.091 I16.211 J-17.064 E.17651
; LINE_WIDTH: 0.74078
G1 F3625.508
G1 X142.65 Y133.094 E.00469
; LINE_WIDTH: 0.790705
G1 F3355.564
G1 X142.683 Y133.097 E.00507
; LINE_WIDTH: 0.840631
G1 F3123.032
G1 X142.716 Y133.1 E.00545
; LINE_WIDTH: 0.890556
G1 F2920.64
G1 X142.749 Y133.102 E.00583
; LINE_WIDTH: 0.940482
G1 F2742.884
G1 X142.782 Y133.105 E.0062
; LINE_WIDTH: 0.990407
G1 F2585.524
G1 X142.815 Y133.108 E.00658
; LINE_WIDTH: 1.04033
G1 F2445.239
G1 X142.848 Y133.111 E.00696
; LINE_WIDTH: 1.09026
G1 F2319.394
G1 X142.881 Y133.114 E.00734
; LINE_WIDTH: 1.14018
G1 F2205.869
G1 X142.914 Y133.116 E.00771
; LINE_WIDTH: 1.19011
G1 F2102.938
G1 X142.947 Y133.119 E.00809
; LINE_WIDTH: 1.24003
G1 F2009.185
G1 X142.98 Y133.122 E.00847
; WIPE_START
G1 X142.947 Y133.119 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.217 Y134.074 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.630049
G1 F3000
M204 S6000
G1 X147.355 Y134.444 E.04587
; LINE_WIDTH: 0.584573
G1 X147.492 Y134.813 E.04178
; LINE_WIDTH: 0.546233
G1 X147.544 Y134.975 E.01649
; LINE_WIDTH: 0.515045
G1 X147.596 Y135.136 E.01529
; WIPE_START
G1 X147.544 Y134.975 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.912 Y134.877 Z3.6 F42000
G1 X112.209 Y134.521 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I6.564 J-7.318 E.44648
G1 X122.192 Y120.612 E2.65852
G2 X119.598 Y119.598 I-4.799 J8.455 E.44634
G1 X134.649 Y134.649 E3.39873
G1 X134.547 Y134.649 E.01622
G1 X138.687 Y130.509 E.93488
G3 X138.688 Y125.492 I3.387 J-2.508 E.85802
G1 X134.547 Y121.351 E.93505
G1 X134.649 Y121.351 E.01628
G1 X119.597 Y136.403 E3.39892
G2 X122.193 Y135.389 I-2.206 J-9.478 E.44651
G1 X110.42 Y123.616 E2.6585
G3 X112.209 Y121.48 I7.5 J4.465 E.44686
; CHANGE_LAYER
; Z_HEIGHT: 3.76
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57241
G1 X110.875 Y122.962 E-.18759
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 7/51
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z3.76 I-.304 J1.676 P1  F42000
G1 X138.456 Y127.961 Z3.76
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X138.458 Y128.065 E.01662
G2 X140.562 Y131.283 I3.612 J-.065 E.64725
G1 X140.601 Y131.819 E.08588
G1 X141.367 Y131.816 E.12232
G2 X142.053 Y132.508 I5.565 J-4.832 E.15574
G1 X145.086 Y134.995 E.62625
G1 X147.071 Y133.11 E.43709
G1 X147.383 Y133.264 E.05555
G3 X147.379 Y134.702 I-19.065 J.676 E.22962
G1 X147.334 Y134.883 E.02992
G1 X147.224 Y135.052 E.03211
G1 X147.053 Y135.179 E.03407
G1 X146.861 Y135.236 E.03197
G3 X146.766 Y135.241 I-.09 J-.824 E.01516
G1 X124.744 Y135.241 E3.51634
G2 X122.78 Y135.739 I.033 J4.249 E.32664
G3 X108.718 Y126.647 I-4.954 J-7.759 E3.35767
G3 X122.097 Y119.874 I9.094 J1.362 E2.79996
G2 X123.42 Y120.539 I3.843 J-5.993 E.23674
G2 X124.74 Y120.76 I1.438 J-4.528 E.21445
G1 X146.819 Y120.761 E3.52551
G1 X147.025 Y120.809 E.03372
G1 X147.185 Y120.911 E.03038
M73 P44 R10
G3 X147.383 Y121.377 I-.405 J.446 E.08344
G1 X147.383 Y122.738 E.21736
G1 X147.101 Y122.871 E.04979
G1 X145.183 Y120.965 E.43176
G1 X145.21 Y121.045 E.01349
G1 X142.423 Y123.185 E.56113
G2 X141.355 Y124.193 I7.894 J9.423 E.23463
G1 X140.615 Y124.19 E.11822
G1 X140.575 Y124.711 E.08348
G2 X138.496 Y127.472 I1.495 J3.289 E.57543
G1 X138.466 Y127.842 E.0592
M204 S10000
G1 X139.153 Y127.999 F42000
G1 F3215.099
M204 S6000
G1 X139.156 Y128.049 E.00812
G2 X141.228 Y130.788 I2.915 J-.052 E.58625
G1 X141.252 Y131.117 E.05262
G1 X141.687 Y131.115 E.06956
G2 X142.521 Y131.986 I6.318 J-5.209 E.19276
G1 X145.052 Y134.062 E.52267
G1 X146.951 Y132.258 E.41811
G2 X148.082 Y132.813 I7.815 J-14.522 E.20129
G1 X148.082 Y134.629 E.29003
G3 X146.776 Y135.94 I-1.293 J.018 E.32937
G1 X124.754 Y135.94 E3.51643
G2 X123.111 Y136.356 I.023 J3.544 E.27325
G3 X117.937 Y118.112 I-5.297 J-8.354 E5.87402
G3 X123.111 Y119.644 I-.17 J10.076 E.87235
G2 X124.751 Y120.06 I1.665 J-3.129 E.27274
G1 X146.776 Y120.06 E3.51683
G3 X148.082 Y121.367 I.012 J1.294 E.3286
G1 X148.082 Y123.183 E.28993
G2 X146.972 Y123.73 I5.687 J12.937 E.19779
G1 X145.181 Y121.949 E.40324
G1 X142.859 Y123.732 E.46741
G2 X141.685 Y124.895 I5.93 J7.164 E.26423
G1 X141.263 Y124.893 E.0673
G1 X141.239 Y125.204 E.04979
G2 X139.187 Y127.574 I.832 J2.794 E.52867
G1 X139.162 Y127.879 E.0488
M204 S250
G1 X139.88 Y128.302 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.896 Y128.46 E.0255
G2 X144.264 Y128.147 I2.163 J-.452 E1.01367
G2 X145.021 Y129.905 I3.099 J-.293 E.31063
G2 X146.47 Y131.16 I5.378 J-4.742 E.30707
G2 X148.782 Y132.354 I7.954 J-12.572 E.41603
G1 X148.782 Y134.642 E.36547
G3 X146.786 Y136.64 I-1.993 J.005 E.50119
G1 X124.763 Y136.64 E3.51648
G2 X123.441 Y136.973 I.013 J2.84 E.21987
G3 X117.96 Y117.412 I-5.628 J-8.972 E6.28357
G3 X123.441 Y119.027 I-.183 J10.728 E.92345
G2 X124.762 Y119.36 I1.335 J-2.507 E.21969
G1 X146.786 Y119.36 E3.51667
G3 X148.782 Y121.356 I.002 J1.994 E.50084
G1 X148.782 Y123.65 E.36624
G2 X145.722 Y125.397 I4.194 J10.903 E.56478
G2 X145.084 Y126.02 I7.656 J8.478 E.14238
G2 X144.264 Y127.865 I2.271 J2.115 E.32846
G2 X139.85 Y128.034 I-2.205 J.144 E1.08931
G1 X139.866 Y128.182 E.02389
; WIPE_START
M204 S6000
G1 X139.896 Y128.46 E-.10628
G1 X140.026 Y128.866 E-.162
G1 X140.24 Y129.255 E-.16839
G1 X140.544 Y129.61 E-.1778
G1 X140.839 Y129.843 E-.14265
G1 X140.845 Y129.847 E-.00288
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


G1 X143.577 Y129.971 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.893897
G1 F2908.029
M204 S2000
G1 X145.973 Y132.367 E.59817
G1 X145.412 Y132.9 E.13663
G1 X143.112 Y130.6 E.57417
G3 X142.219 Y130.802 I-1.099 J-2.786 E.16216
G1 X145.073 Y133.656 E.7125
; WIPE_START
M204 S6000
G1 X143.659 Y132.241 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.701 Y134.429 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.878577
G1 F2966.772
M204 S6000
G1 X146.606 Y134.429 E.0164
G1 X146.559 Y134.512 E.0164
G1 X146.606 Y134.594 E.0164
G1 X146.676 Y134.594 E.01204
; WIPE_START
G1 X146.606 Y134.594 E-.14942
G1 X146.559 Y134.512 E-.20353
G1 X146.606 Y134.429 E-.20353
G1 X146.701 Y134.429 E-.20352
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.07 Y134.573 Z4.16 F42000
G1 X137.861 Y134.595 Z4.16
G1 Z3.76
G1 E.8 F1800
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
;_EXTRUDE_SET_SPEED
M204 S6000
G1 X143.456 Y134.594 E.86813
; Slow Down End
; WIPE_START
G1 X141.456 Y134.594 E-.76
; WIPE_END
G1 E-.04
M204 S10000
G1 X140.354 Y127.042 Z4.16 F42000
G1 X139.955 Y124.307 Z4.16
G1 Z3.76
G1 E.8 F1800
G1 F3308.823
M204 S6000
G1 X139.278 Y124.776 E.12782
G1 X138.759 Y125.317 E.11633
G1 X138.356 Y125.905 E.1106
G1 X138.136 Y126.368 E.07945
G1 X137.917 Y127.058 E.11235
G2 X138.141 Y129.647 I4.245 J.937 E.40953
G1 X138.346 Y130.084 E.07487
G2 X139.094 Y131.053 I4.337 J-2.573 E.19044
G1 X139.689 Y131.532 E.1185
G1 X139.839 Y131.619 E.02693
; WIPE_START
G1 X139.689 Y131.532 E-.06596
G1 X139.094 Y131.053 E-.29024
G1 X138.683 Y130.582 E-.23752
G1 X138.438 Y130.22 E-.16628
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.339 Y124.369 Z4.16 F42000
G1 X144.874 Y122.538 Z4.16
G1 Z3.76
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.914297
G1 F2833.325
M204 S2000
G1 X146.473 Y124.138 E.40989
G2 X145.796 Y124.584 I8.86 J14.169 E.1469
G1 X144.528 Y123.316 E.32504
G1 X143.894 Y123.805 E.14507
G1 X145.181 Y125.092 E.32962
G2 X144.617 Y125.651 I2.385 J2.966 E.14415
G1 X143.261 Y124.295 E.34757
G1 X142.876 Y124.592 E.08803
G1 X142.804 Y124.58 E.01328
G3 X142.608 Y124.765 I-2.981 J-2.961 E.04883
M73 P45 R10
G1 X144.373 Y126.53 E.45225
; WIPE_START
M204 S6000
G1 X142.959 Y125.116 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.715 Y121.384 Z4.16 F42000
G1 Z3.76
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.816997
G1 F3228.955
M204 S6000
G2 X146.628 Y121.535 I-.033 J.082 E.03994
G1 X146.682 Y121.535 E.00862
; WIPE_START
G1 X146.628 Y121.535 E-.13054
G1 X146.584 Y121.46 E-.20982
G1 X146.628 Y121.384 E-.20982
G1 X146.715 Y121.384 E-.20982
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.082 Y121.395 Z4.16 F42000
G1 X133.315 Y121.404 Z4.16
G1 Z3.76
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X142.464 Y121.407 E1.41963
G1 X142.882 Y121.605 E.07173
G1 X142.97 Y121.907 E.04887
M204 S10000
G1 X112.21 Y121.48 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.42 Y123.616 I5.684 J6.58 E.44687
G1 X122.193 Y135.389 E2.6585
G3 X119.597 Y136.403 I-4.811 J-8.486 E.44652
G1 X133.949 Y122.051 E3.24081
G1 X135.247 Y122.051 E.20737
G1 X138.187 Y124.991 E.66373
G2 X138.192 Y131.004 I3.991 J3.003 E1.03027
G1 X134.547 Y134.649 E.82311
G1 X134.649 Y134.649 E.0162
G1 X119.598 Y119.598 E3.39874
G3 X122.196 Y120.608 I-2.283 J9.719 E.44662
G1 X110.42 Y132.384 E2.65912
G2 X112.209 Y134.52 I8.315 J-5.143 E.44647
; CHANGE_LAYER
; Z_HEIGHT: 4.32
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.173 Y133.463 E-.56256
G1 X110.876 Y133.037 E-.19744
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 8/51
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change
M106 S196.35
; OBJECT_ID: 15
M204 S10000
G17
G3 Z4.32 I.283 J1.68 P1  F42000
G1 X138.476 Y128.386 Z4.32
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X138.511 Y128.617 E.03722
G2 X142.9 Y131.508 I3.555 J-.619 E.94005
G2 X145.719 Y133.294 I7.835 J-9.252 E.53448
G2 X147.383 Y133.981 I9.666 J-21.064 E.28749
G3 X147.373 Y134.75 I-4.564 J.33 E.12308
G1 X147.368 Y134.778 E.00458
G3 X146.766 Y135.241 I-.579 J-.132 E.13135
G1 X124.744 Y135.241 E3.51638
G2 X122.78 Y135.739 I.033 J4.249 E.32668
G3 X108.655 Y127.174 I-4.956 J-7.756 E3.27363
G1 X108.659 Y127.14 E.00549
G3 X117.926 Y118.812 I9.16 J.872 E2.18548
G3 X122.781 Y120.262 I-.16 J9.387 E.81922
G2 X124.739 Y120.76 I1.996 J-3.751 E.32581
G1 X146.766 Y120.76 E3.51704
G3 X147.383 Y121.377 I.021 J.596 E.1563
G1 X147.383 Y122.019 E.1026
G2 X143.598 Y123.934 I5.126 J14.832 E.67936
G2 X142.918 Y124.492 I3.559 J5.03 E.14055
G2 X138.462 Y128.171 I-.852 J3.506 E1.06991
G1 X138.468 Y128.267 E.01531
M204 S10000
G1 X139.171 Y128.31 F42000
G1 F3215.099
M204 S6000
G1 X139.194 Y128.495 E.02983
G2 X143.101 Y130.721 I2.868 J-.492 E.82053
G2 X145.386 Y132.346 I6.489 J-6.702 E.4495
G2 X148.082 Y133.489 I9.123 J-17.781 E.46804
G3 X148.08 Y134.726 I-21.167 J.572 E.19753
G3 X146.776 Y135.94 I-1.295 J-.083 E.31364
G1 X124.754 Y135.94 E3.51642
G2 X123.111 Y136.356 I.023 J3.544 E.27328
G3 X117.948 Y118.112 I-5.296 J-8.354 E5.87536
G3 X123.111 Y119.644 I-.18 J10.07 E.87047
G2 X124.751 Y120.06 I1.666 J-3.128 E.27275
G1 X146.776 Y120.06 E3.51688
G3 X148.082 Y121.366 I.012 J1.295 E.32851
G1 X148.082 Y122.514 E.18325
G2 X144.541 Y124.14 I5.65 J16.979 E.62341
G2 X143.101 Y125.286 I4.244 J6.812 E.29457
G2 X139.155 Y128.142 I-1.04 J2.718 E.92165
G1 X139.16 Y128.19 E.00782
M204 S250
G1 X139.86 Y128.18 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.867 Y128.233 E.00849
G2 X143.258 Y129.857 I2.195 J-.232 E.71825
G2 X145.269 Y131.483 I5.525 J-4.776 E.41516
G2 X148.782 Y132.982 I9.155 J-16.582 E.61095
G3 X148.779 Y134.766 I-30.554 J.831 E.2849
G3 X146.786 Y136.64 I-1.996 J-.126 E.48094
G1 X124.763 Y136.64 E3.51649
G2 X123.441 Y136.974 I.013 J2.84 E.2199
G3 X107.269 Y126.973 I-5.626 J-8.979 E3.76791
G3 X117.971 Y117.413 I10.55 J1.04 E2.51678
G3 X123.441 Y119.027 I-.2 J10.754 E.92176
G2 X124.762 Y119.36 I1.335 J-2.506 E.21968
G1 X146.786 Y119.36 E3.51669
G3 X148.782 Y121.356 I.002 J1.994 E.50077
G1 X148.782 Y123.017 E.26518
G2 X144.915 Y124.732 I5.305 J17.184 E.67712
G2 X143.258 Y126.145 I3.904 J6.254 E.3489
G2 X139.857 Y127.912 I-1.196 J1.856 E.74135
G1 X139.858 Y128.06 E.02365
; WIPE_START
M204 S6000
G1 X139.867 Y128.233 E-.06569
G1 X139.923 Y128.567 E-.12879
G1 X140.026 Y128.866 E-.11984
G1 X140.126 Y129.071 E-.08694
G1 X140.223 Y129.231 E-.07097
G1 X140.419 Y129.481 E-.12081
G1 X140.622 Y129.679 E-.10784
G1 X140.748 Y129.77 E-.05912
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


G1 X142.853 Y132.052 F42000
G1 Z4.32
G1 E.8 F1800
M106 S255
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.802004
G1 F3299.957
M204 S6000
G2 X144.73 Y133.58 I16.738 J-18.647 E.37671
; LINE_WIDTH: 0.839775
G1 F3126.746
G1 X144.856 Y133.671 E.02543
; LINE_WIDTH: 0.889611
G1 F2924.228
G1 X144.982 Y133.761 E.0272
; LINE_WIDTH: 0.939447
G1 F2746.348
G1 X145.108 Y133.852 E.02896
; LINE_WIDTH: 0.989283
G1 F2588.867
G1 X145.233 Y133.942 E.03072
; LINE_WIDTH: 1.03912
G1 F2448.468
G1 X145.359 Y134.033 E.03248
; LINE_WIDTH: 1.08752
G1 F2325.966
G1 X145.441 Y134.089 E.02184
; LINE_WIDTH: 1.13448
G1 F2218.279
G1 X145.522 Y134.145 E.0229
; LINE_WIDTH: 1.18144
G1 F2120.121
G1 X145.604 Y134.201 E.02396
; LINE_WIDTH: 1.2284
G1 F2030.283
G1 X145.685 Y134.257 E.02502
; WIPE_START
G1 X145.604 Y134.201 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.904 Y126.601 Z4.72 F42000
G1 X144.522 Y122.455 Z4.72
G1 Z4.32
G1 E.8 F1800
; LINE_WIDTH: 0.954137
G1 F2697.971
M204 S6000
G3 X146.523 Y121.527 I7.897 J14.407 E.4201
G1 X143.593 Y121.526 E.55761
G1 X144.437 Y122.37 E.22718
M204 S10000
G1 X129.528 Y124.846 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
M73 P46 R10
G1 F3215.099
M204 S6000
G1 X128.362 Y126.012 E.26333
G1 X129.175 Y126.825 E.18364
G1 X119.597 Y136.403 E2.16285
G2 X122.193 Y135.389 I-2.222 J-9.518 E.44653
G1 X110.42 Y123.616 E2.6585
G2 X110.42 Y132.384 I7.387 J4.384 E1.46924
G1 X122.192 Y120.612 E2.65831
G2 X119.598 Y119.598 I-4.814 J8.492 E.44636
G1 X134.649 Y134.649 E3.39875
G1 X134.547 Y134.649 E.0162
G1 X135.773 Y133.423 E.27679
G1 X133.794 Y131.444 E.44698
M204 S10000
G1 X129.197 Y125.731 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.82834
; LAYER_HEIGHT: 0.8
G1 F1800
M204 S6000
G1 X138.039 Y134.573 E2.74544
G1 X139.281 Y134.573 E.27267
G1 X130.089 Y125.381 E2.85422
G1 X130.71 Y124.76 E.19285
G1 X140.523 Y134.572 E3.04698
G1 X141.765 Y134.572 E.27267
G1 X131.331 Y124.138 E3.23974
G1 X131.952 Y123.517 E.19285
G1 X143.006 Y134.572 E3.43251
G1 X144.248 Y134.571 E.27267
G1 X141.531 Y131.854 E.84382
M106 S196.35
M106 S255
; WIPE_START
G1 X142.945 Y133.268 E-.76
; WIPE_END
G1 E-.04
M204 S10000
G1 X138.203 Y128.526 Z4.72 F42000
G1 Z4.32
G1 E.8 F1800

M204 S6000
G1 X132.573 Y122.896 E1.74802
G1 X133.194 Y122.275 E.19285
G1 X137.902 Y126.983 E1.4619
G3 X138.242 Y126.081 I5.133 J1.42 E.21196
G1 X133.587 Y121.426 E1.44563
G1 X134.829 Y121.426 E.27283
G1 X138.722 Y125.318 E1.20856
G3 X139.344 Y124.698 I3.638 J3.028 E.19309
G1 X136.072 Y121.426 E1.01589
G1 X137.315 Y121.427 E.27283
G1 X140.088 Y124.2 E.86123
G1 X140.55 Y124.002 E.11037
G3 X140.987 Y123.857 I1.347 J3.319 E.10116
G1 X138.557 Y121.427 E.75454
G1 X139.8 Y121.428 E.27282
G1 X142.094 Y123.722 E.71237
G3 X142.668 Y123.773 I.084 J2.303 E.12698
G1 X143.074 Y123.46 E.11251
G1 X141.042 Y121.428 E.63086
G1 X142.285 Y121.428 E.27282
G1 X144.047 Y123.191 E.54731
M106 S196.35
; CHANGE_LAYER
; Z_HEIGHT: 4.88
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F1800
G1 X142.633 Y121.777 E-.76
; WIPE_END
G1 E-.04
; layer num/total_layer_count: 9/51
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change
M106 S198.9
; OBJECT_ID: 15
M204 S10000
G17
G3 Z4.88 I-1.45 J-.894 P1  F42000
G1 X138.485 Y128.503 Z4.88
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X138.493 Y128.57 E.01071
G2 X141.162 Y131.496 I3.563 J-.569 E.66934
G2 X144.684 Y133.6 I8.239 J-9.789 E.6579
G2 X147.402 Y134.553 I9.347 J-22.323 E.46019
G3 X146.901 Y135.23 I-.674 J.025 E.14533
G1 X146.86 Y135.236 E.00651
G3 X146.766 Y135.241 I-.089 J-.817 E.01504
G1 X124.744 Y135.241 E3.51639
G2 X122.78 Y135.739 I.033 J4.248 E.32681
G3 X109.515 Y124.04 I-4.954 J-7.752 E3.79429
G3 X117.937 Y118.812 I8.304 J3.979 E1.67132
G3 X122.781 Y120.262 I-.169 J9.383 E.81746
G2 X124.739 Y120.76 I1.997 J-3.75 E.32573
G1 X146.766 Y120.76 E3.51721
G3 X147.371 Y121.239 I.022 J.594 E.13408
G1 X147.402 Y121.443 E.03301
G2 X143.043 Y123.193 I6.223 J21.809 E.75129
G2 X141.184 Y124.5 I4.465 J8.324 E.36365
G2 X138.454 Y128.203 I.872 J3.501 E.79663
G1 X138.473 Y128.384 E.02909
M204 S10000
G1 X139.181 Y128.424 F42000
G1 F3215.099
M204 S6000
G1 X139.187 Y128.459 E.00569
G2 X141.521 Y130.862 I2.877 J-.46 E.56972
G2 X143.626 Y132.327 I6.502 J-7.097 E.41077
G2 X148.082 Y134.023 I10.176 J-20.03 E.7628
G3 X148.049 Y134.937 I-4.221 J.305 E.14633
G3 X146.776 Y135.94 I-1.26 J-.289 E.27976
G1 X124.754 Y135.94 E3.51645
G2 X123.11 Y136.357 I.023 J3.544 E.27338
G3 X117.959 Y118.112 I-5.296 J-8.354 E5.87734
G3 X123.111 Y119.644 I-.189 J10.066 E.86874
G2 X124.75 Y120.06 I1.666 J-3.128 E.27272
G1 X146.776 Y120.06 E3.51696
G3 X148.082 Y121.367 I.014 J1.293 E.32866
G1 X148.082 Y121.981 E.09808
G2 X143.384 Y123.804 I5.599 J21.396 E.80651
G2 X141.533 Y125.134 I3.945 J7.44 E.36504
G2 X139.156 Y128.163 I.531 J2.865 E.67166
G1 X139.169 Y128.305 E.02273
M204 S250
G1 X139.859 Y128.046 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.888 Y128.347 E.04831
G2 X141.845 Y130.198 I2.182 J-.347 E.4626
G2 X143.566 Y131.494 I5.721 J-5.807 E.34497
G2 X148.177 Y133.322 I9.895 J-18.237 E.79394
G1 X148.782 Y133.483 E.1
G3 X148.779 Y134.766 I-21.985 J.58 E.20491
G3 X146.786 Y136.64 I-1.996 J-.126 E.48092
G1 X124.763 Y136.64 E3.51651
G2 X123.441 Y136.974 I.012 J2.839 E.21994
G3 X117.981 Y117.413 I-5.628 J-8.972 E6.28682
G3 X123.441 Y119.027 I-.21 J10.75 E.92002
G2 X124.762 Y119.36 I1.335 J-2.506 E.21971
G1 X146.786 Y119.36 E3.51671
M73 P47 R10
G3 X148.782 Y121.356 I.004 J1.992 E.50093
G1 X148.782 Y122.518 E.18543
G2 X144.312 Y124.108 I5.895 J23.652 E.75871
G2 X142.236 Y125.431 I4.481 J9.324 E.39411
G1 X141.847 Y125.803 E.08588
G2 X139.862 Y127.904 I.222 J2.198 E.50318
G1 X139.862 Y127.926 E.00356
; WIPE_START
M204 S6000
G1 X139.888 Y128.347 E-.16034
G1 X139.988 Y128.773 E-.16601
G1 X140.176 Y129.158 E-.1628
G1 X140.416 Y129.478 E-.1522
G1 X140.648 Y129.687 E-.11865
; WIPE_END
M73 P47 R9
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


G1 X143.953 Y134.296 F42000
G1 Z4.88
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X143.998 Y134.061 E.03829
G3 X141.302 Y132.515 I5.636 J-12.954 E.49727
G1 X140.82 Y132.12 E.09947
G1 X140.331 Y131.948 E.08269
G1 X139.561 Y131.512 E.1413
G1 X138.879 Y130.909 E.1454
G1 X138.403 Y130.284 E.12538
G1 X138.042 Y129.557 E.12964
G3 X137.797 Y128.645 I9.895 J-3.142 E.15079
G1 X137.752 Y127.846 E.12785
G1 X137.873 Y126.973 E.14068
G1 X138.078 Y126.349 E.10488
G3 X138.836 Y125.141 I4.556 J2.016 E.22859
G1 X139.472 Y124.554 E.1382
G1 X140.066 Y124.178 E.11222
G3 X140.834 Y123.879 I14.772 J36.843 E.13157
G3 X142.694 Y122.586 I7.346 J8.58 E.36229
G3 X143.993 Y121.947 I6.397 J11.364 E.23126
G1 X143.903 Y121.459 E.07928
G1 X137.557 Y121.457 E1.01321
G1 X135.182 Y123.42 E.49202
G1 X134.49 Y124.099 E.15487
G1 X133.892 Y124.86 E.15446
G1 X133.562 Y125.406 E.10194
G1 X133.201 Y126.221 E.14227
G1 X133.028 Y126.806 E.09747
G1 X132.895 Y127.707 E.14537
G2 X132.98 Y128.922 I4.415 J.304 E.19509
G1 X133.124 Y129.555 E.10368
G1 X133.527 Y130.532 E.16875
G1 X134.029 Y131.333 E.15096
G2 X135.097 Y132.508 I6.378 J-4.726 E.25399
G1 X137.567 Y134.543 E.51101
G1 X143.906 Y134.541 E1.01205
G1 X143.93 Y134.414 E.02072
M204 S10000
G1 X142.04 Y133.842 F42000
G1 F3215.112
M204 S6000
G3 X140.471 Y132.739 I6.219 J-10.517 E.30655
G1 X139.924 Y132.528 E.09354
G1 X139.212 Y132.119 E.13114
G1 X138.411 Y131.429 E.16883
G1 X137.843 Y130.703 E.14717
G1 X137.413 Y129.864 E.15056
G1 X137.173 Y129.049 E.1356
G1 X137.099 Y128.685 E.05936
G1 X137.053 Y127.886 E.12785
G3 X137.224 Y126.688 I9.462 J.745 E.19332
G3 X138.275 Y124.716 I4.889 J1.339 E.35968
G1 X138.957 Y124.076 E.14939
G1 X139.697 Y123.583 E.14202
G1 X140.39 Y123.299 E.11948
G1 X140.553 Y123.205 E.03016
G3 X142.044 Y122.158 I7.109 J8.535 E.29115
G1 X137.809 Y122.157 E.67622
G1 X135.651 Y123.94 E.44701
G1 X135.012 Y124.567 E.14291
G1 X134.469 Y125.258 E.14037
G1 X134.184 Y125.73 E.08803
G1 X133.859 Y126.463 E.12793
G1 X133.714 Y126.957 E.08232
G1 X133.595 Y127.758 E.12931
G1 X133.595 Y128.279 E.08309
G1 X133.752 Y129.159 E.14279
G1 X134.038 Y129.935 E.1321
G1 X134.224 Y130.326 E.06912
G2 X135.045 Y131.469 I4.845 J-2.615 E.22535
G1 X135.568 Y131.989 E.11767
G1 X137.818 Y133.843 E.46563
G1 X141.92 Y133.842 E.65489
M204 S10000
G1 X139.487 Y133.115 F42000
; LINE_WIDTH: 0.883904
G1 F2946.079
M204 S6000
G1 X138.85 Y132.749 E.12801
G1 X137.919 Y131.976 E.2109
G1 X137.671 Y131.727 E.06117
; LINE_WIDTH: 0.904414
G1 F2869.032
G1 X137.542 Y131.525 E.04288
; LINE_WIDTH: 0.870647
G1 F2998.121
G1 X137.412 Y131.324 E.04103
; LINE_WIDTH: 0.820575
G1 F3212.459
G1 X137.283 Y131.122 E.03829
G1 X136.784 Y130.171 E.17163
G1 X136.496 Y129.228 E.15754
G1 X136.4 Y128.725 E.08185
G1 X136.354 Y127.926 E.12795
G3 X136.507 Y126.664 I11.546 J.758 E.20327
G1 X136.752 Y125.901 E.12799
G1 X136.978 Y125.396 E.08841
G1 X137.37 Y124.745 E.12138
; LINE_WIDTH: 0.839517
G1 F3127.867
G1 X137.524 Y124.512 E.0459
; LINE_WIDTH: 0.881361
G1 F2955.921
G1 X137.678 Y124.279 E.04857
G1 X138.463 Y123.541 E.1871
G3 X139.473 Y122.885 I3.971 J5.011 E.20948
G1 X138.071 Y122.885 E.24362
G1 X137.348 Y123.497 E.16452
; LINE_WIDTH: 0.879239
G1 F2964.183
G1 X137.075 Y123.697 E.05856
; LINE_WIDTH: 0.820669
G1 F3212.028
G2 X135.535 Y125.035 I7.48 J10.164 E.32646
G1 X135.046 Y125.657 E.1264
G2 X134.295 Y127.81 I3.841 J2.548 E.36825
G1 X134.325 Y128.499 E.11036
G1 X134.434 Y129.004 E.08241
G2 X135.168 Y130.515 I5.147 J-1.565 E.26964
G2 X136.51 Y131.859 I5.963 J-4.613 E.30446
; LINE_WIDTH: 0.83688
G1 F3139.374
G1 X136.706 Y131.998 E.03918
; LINE_WIDTH: 0.870647
G1 F2998.121
G1 X136.901 Y132.137 E.04103
; LINE_WIDTH: 0.886957
G1 F2934.349
G1 X137.096 Y132.276 E.04192
G2 X138.079 Y133.116 I21.507 J-24.182 E.22625
G1 X139.367 Y133.115 E.22523
M204 S10000
G1 X136.485 Y131.013 F42000
; LINE_WIDTH: 0.695407
G1 F3911.479
M204 S6000
G3 X135.88 Y129.391 I5.395 J-2.938 E.22794
; LINE_WIDTH: 0.71229
G1 F3799.954
G1 X135.806 Y129.097 E.04089
; LINE_WIDTH: 0.746055
G1 F3594.953
G1 X135.732 Y128.804 E.04322
; LINE_WIDTH: 0.771899
G1 F3452.392
G3 X135.826 Y126.672 I6.289 J-.792 E.31887
G3 X136.338 Y125.185 I7.007 J1.58 E.23428
G2 X135.598 Y126.038 I4.054 J4.263 E.16816
G2 X135.141 Y126.956 I4.806 J2.962 E.15267
G2 X135.104 Y128.925 I3.664 J1.053 E.29622
; LINE_WIDTH: 0.748752
G1 F3579.525
G1 X135.192 Y129.174 E.03782
; LINE_WIDTH: 0.698986
G1 F3887.293
G2 X135.358 Y129.617 I4.769 J-1.535 E.06249
G2 X136.399 Y130.929 I4.754 J-2.701 E.22211
M204 S10000
G1 X133.48 Y131.769 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X135.472 Y133.724 I8.308 J-6.471 E.44688
G1 X134.547 Y134.649 E.20875
G1 X134.649 Y134.649 E.01619
G1 X119.599 Y119.599 E3.39837
G3 X122.192 Y120.612 I-2.2 J9.463 E.44603
G1 X110.42 Y132.384 E2.65827
G3 X110.42 Y123.616 I7.387 J-4.384 E1.4692
G1 X122.193 Y135.389 E2.65851
G3 X119.598 Y136.402 I-4.771 J-8.392 E.44634
G1 X134.649 Y121.351 E3.39877
G1 X134.547 Y121.351 E.01638
G1 X135.47 Y122.274 E.20846
G2 X133.482 Y124.233 I5.262 J7.326 E.44737
M204 S10000
G1 X144.632 Y121.557 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.855498
G1 F3000
M204 S6000
G1 X144.841 Y121.518 E.03556
; LINE_WIDTH: 0.812864
G1 X145.049 Y121.48 E.0335
; LINE_WIDTH: 0.770229
G1 X145.258 Y121.442 E.03144
; LINE_WIDTH: 0.727595
G1 X145.466 Y121.403 E.02938
; LINE_WIDTH: 0.704692
G1 X145.475 Y121.402 E.00121
; LINE_WIDTH: 0.679279
G1 X145.616 Y121.378 E.01826
; LINE_WIDTH: 0.631625
G1 X145.757 Y121.354 E.0167
; LINE_WIDTH: 0.583971
G1 X145.898 Y121.33 E.01514
; LINE_WIDTH: 0.536317
G1 X146.04 Y121.307 E.01359
; LINE_WIDTH: 0.488663
G1 X146.181 Y121.283 E.01203
; LINE_WIDTH: 0.441009
G1 X146.322 Y121.259 E.01048
; LINE_WIDTH: 0.392736
G1 X146.481 Y121.235 E.01002
; LINE_WIDTH: 0.344668
G1 X146.636 Y121.211 E.00801
; LINE_WIDTH: 0.297298
G1 X146.79 Y121.187 E.00632
; LINE_WIDTH: 0.250179
G3 X146.988 Y121.185 I.112 J.999 E.00588
; WIPE_START
G1 X146.79 Y121.187 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.567 Y128.721 Z5.28 F42000
G1 X144.637 Y134.442 Z5.28
G1 Z4.88
G1 E.8 F1800
; LINE_WIDTH: 0.859367
G1 F3000
M204 S6000
G1 X144.904 Y134.493 E.04587
; LINE_WIDTH: 0.827895
G1 X145.172 Y134.544 E.04392
; LINE_WIDTH: 0.809949
G1 X145.184 Y134.547 E.00192
; LINE_WIDTH: 0.783612
G1 X145.322 Y134.571 E.02124
; LINE_WIDTH: 0.735346
G1 X145.46 Y134.595 E.01969
; LINE_WIDTH: 0.687081
G1 X145.598 Y134.619 E.01815
; LINE_WIDTH: 0.638815
G1 X145.736 Y134.643 E.0166
; LINE_WIDTH: 0.59055
G1 X145.875 Y134.667 E.01506
; LINE_WIDTH: 0.542284
G1 X146.013 Y134.691 E.01351
; LINE_WIDTH: 0.517132
G1 X146.019 Y134.692 E.00057
; LINE_WIDTH: 0.491412
G1 X146.175 Y134.717 E.01334
; LINE_WIDTH: 0.442063
G1 X146.33 Y134.741 E.01157
; LINE_WIDTH: 0.392714
G1 X146.486 Y134.766 E.00979
; LINE_WIDTH: 0.343365
M73 P48 R9
G1 X146.641 Y134.79 E.00802
; LINE_WIDTH: 0.294016
G1 X146.797 Y134.815 E.00625
; LINE_WIDTH: 0.237893
G2 X146.865 Y134.818 I.048 J-.338 E.00184
G1 X146.989 Y134.816 E.00333
; CHANGE_LAYER
; Z_HEIGHT: 5.44
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3000
G1 X146.865 Y134.818 E-.48946
G1 X146.797 Y134.815 E-.27054
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 10/51
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change
M106 S196.35
; OBJECT_ID: 15
M204 S10000
G17
G3 Z5.44 I.682 J-1.561 P1  F42000
G1 X134.919 Y129.63 Z5.44
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X134.98 Y129.821 E.03204
G2 X135.649 Y131.116 I5.091 J-1.815 E.23338
G2 X136.857 Y132.486 I7.453 J-5.354 E.29213
G1 X139.951 Y135.03 E.63949
G1 X141.909 Y133.116 E.43729
G2 X146.847 Y134.876 I10.94 J-22.887 E.83856
G1 X146.799 Y135.241 E.05876
G1 X124.744 Y135.241 E3.52162
G2 X122.779 Y135.74 I.033 J4.248 E.32683
G3 X109.514 Y124.042 I-4.954 J-7.752 E3.79399
G3 X122.78 Y120.261 I8.312 J4 E2.48809
G2 X124.738 Y120.76 I1.997 J-3.75 E.32569
G1 X146.8 Y120.76 E3.52279
G1 X146.847 Y121.127 E.05915
G2 X141.912 Y122.878 I6.101 J25.023 E.8375
G1 X139.927 Y120.976 E.43905
G1 X136.947 Y123.439 E.61729
G2 X135.033 Y126.05 I4.572 J5.359 E.5215
G2 X134.84 Y129.369 I5.038 J1.957 E.53969
G1 X134.885 Y129.515 E.02437
M204 S10000
G1 X135.589 Y129.426 F42000
G1 F3215.099
M204 S6000
G1 X135.636 Y129.58 E.02572
G2 X136.23 Y130.724 I4.424 J-1.572 E.20639
G2 X137.327 Y131.966 I6.744 J-4.853 E.26508
G1 X139.91 Y134.091 E.5341
G1 X141.781 Y132.263 E.41756
G2 X146.174 Y133.97 I10.137 J-19.586 E.75402
G2 X148.082 Y134.456 I10.548 J-37.447 E.31445
G3 X146.777 Y135.94 I-1.305 J.169 E.35726
G1 X124.754 Y135.94 E3.51651
G2 X123.11 Y136.357 I.023 J3.543 E.2734
G3 X117.969 Y118.113 I-5.297 J-8.354 E5.87918
G3 X123.111 Y119.644 I-.186 J10.022 E.86722
G2 X124.75 Y120.06 I1.666 J-3.128 E.2727
G1 X146.776 Y120.06 E3.51698
G3 X148.082 Y121.55 I.001 J1.317 E.35814
G2 X142.291 Y123.474 I5.374 J25.852 E.97671
G1 X141.794 Y123.734 E.08952
G1 X139.892 Y121.913 E.42046
G1 X137.412 Y123.962 E.51373
G2 X135.686 Y126.302 I4.107 J4.838 E.46853
G2 X135.515 Y129.188 I4.374 J1.706 E.46914
G1 X135.553 Y129.312 E.0207
; WIPE_START
G1 X135.636 Y129.58 E-.10681
G1 X135.796 Y129.964 E-.15783
G1 X135.952 Y130.267 E-.12965
G1 X136.23 Y130.724 E-.20315
G1 X136.486 Y131.066 E-.16255
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.095 Y127.997 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X139.118 Y128.335 E.054
G2 X139.686 Y129.694 I2.686 J-.324 E.23824
G2 X141.629 Y131.366 I5.362 J-4.266 E.41171
G2 X145.708 Y133.102 I9.468 J-16.58 E.70948
G2 X148.782 Y133.888 I13.875 J-47.886 E.50676
G3 X148.753 Y134.988 I-6.412 J.381 E.17589
G3 X146.786 Y136.64 I-1.972 J-.35 E.44529
G1 X124.763 Y136.64 E3.51652
G2 X123.44 Y136.974 I.012 J2.839 E.21998
G3 X117.991 Y117.413 I-5.628 J-8.971 E6.28874
G3 X123.441 Y119.027 I-.212 J10.725 E.91844
G2 X124.762 Y119.36 I1.335 J-2.506 E.21971
G1 X146.786 Y119.36 E3.51674
G3 X148.782 Y121.356 I.004 J1.992 E.50092
G1 X148.782 Y122.113 E.12085
G2 X143.239 Y123.805 I5.586 J28.233 E.92701
G2 X140.493 Y125.448 I4.381 J10.441 E.51266
G2 X139.372 Y126.825 I3.079 J3.65 E.28523
G2 X139.102 Y127.878 I2.432 J1.185 E.17469
; WIPE_START
M204 S6000
G1 X139.118 Y128.335 E-.17384
G1 X139.177 Y128.661 E-.12617
G1 X139.31 Y129.04 E-.15238
G1 X139.417 Y129.263 E-.09397
G1 X139.686 Y129.694 E-.19317
G1 X139.72 Y129.736 E-.02046
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


G1 X140.949 Y131.255 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.827327
G1 F3181.786
M204 S2000
G1 X139.347 Y132.857 E.36562
G1 X138.798 Y132.406 E.11464
G1 X140.158 Y131.045 E.31038
G3 X139.643 Y130.561 I2.375 J-3.046 E.11431
G1 X138.328 Y131.876 E.30008
G1 X138.131 Y131.586 E.0566
G1 X137.779 Y131.424 E.06241
G1 X139.187 Y130.017 E.32116
G3 X138.817 Y129.387 I3.499 J-2.479 E.11803
G1 X137.203 Y131.001 E.36822
G3 X136.76 Y130.443 I5.314 J-4.672 E.1149
G1 X138.562 Y128.641 E.41118
G3 X138.51 Y127.694 I3.161 J-.651 E.15366
G1 X136.388 Y129.815 E.48407
G3 X136.107 Y129.097 I4.568 J-2.204 E.12464
G1 X141.207 Y123.996 E1.16384
G1 X140.697 Y123.507 E.11412
G1 X135.958 Y128.245 E1.08123
G3 X136.043 Y127.16 I3.879 J-.243 E.17614
G1 X140.186 Y123.017 E.94534
G1 X139.863 Y122.708 E.07207
G1 X138.341 Y123.967 E.3186
G1 X138.335 Y124.112 E.0235
G1 X138.133 Y124.413 E.05851
G1 X137.469 Y124.734 E.11901
G1 X136.055 Y126.148 E.32257
; WIPE_START
M204 S6000
G1 X137.469 Y124.734 E-.75972
G1 X137.47 Y124.734 E-.00028
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.896 Y122.151 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X134.69 Y121.494 E.16457
G1 X134.547 Y121.351 E.03244
G1 X134.649 Y121.351 E.01643
G3 X132.275 Y123.598 I-81.823 J-84.074 E.52195
G2 X131.732 Y124.268 I32.86 J27.188 E.13784
G1 X119.598 Y136.402 E2.73991
G2 X122.193 Y135.389 I-2.179 J-9.413 E.44629
G1 X110.42 Y123.616 E2.65852
G2 X110.421 Y132.383 I7.389 J4.383 E1.46917
G1 X122.192 Y120.612 E2.65824
G2 X119.6 Y119.6 I-4.761 J8.37 E.44599
G1 X131.782 Y131.782 E2.75086
G2 X133.613 Y133.613 I7.457 J-5.625 E.4149
G1 X134.649 Y134.649 E.23387
G1 X134.547 Y134.649 E.01619
G1 X134.693 Y134.503 E.03291
G1 X133.883 Y133.836 E.16759
M204 S10000
G1 X138.257 Y134.543 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.113
M204 S6000
G1 X136.4 Y133.016 E.3839
G3 X134.903 Y131.247 I6.149 J-6.722 E.37092
G3 X134.163 Y129.571 I6.675 J-3.948 E.29329
G3 X133.961 Y127.744 I8.222 J-1.834 E.29402
G1 X134.098 Y126.717 E.16546
G3 X134.611 Y125.284 I7.326 J1.816 E.24342
M73 P49 R9
G3 X135.237 Y124.256 I16.933 J9.602 E.1923
G1 X135.762 Y123.617 E.13201
G1 X136.469 Y122.928 E.15763
G3 X138.247 Y121.457 I111.143 J132.51 E.36848
G1 X135.835 Y121.456 E.38518
G1 X133.439 Y123.437 E.49638
G1 X132.775 Y124.09 E.14867
G1 X132.135 Y124.908 E.16586
G1 X131.639 Y125.808 E.16411
G2 X131.311 Y126.781 I6.189 J2.629 E.16408
G1 X131.173 Y127.687 E.14628
G2 X131.355 Y129.442 I6.573 J.206 E.28267
G1 X131.64 Y130.196 E.12869
G1 X132.119 Y131.058 E.15739
G2 X133.361 Y132.497 I7.361 J-5.093 E.30415
G1 X135.843 Y134.543 E.51358
G1 X138.137 Y134.543 E.36635
; WIPE_START
G1 X136.137 Y134.543 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.476 Y126.94 Z5.84 F42000
G1 X135.142 Y123.088 Z5.84
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 1.0298
G1 F2473.547
M204 S6000
G1 X135.537 Y122.732 E.11037
; LINE_WIDTH: 0.979938
G1 F2617.006
G3 X136.019 Y122.302 I6.379 J6.679 E.12679
; WIPE_START
G1 X135.537 Y122.732 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.113 Y130.23 Z5.84 F42000
G1 X133.795 Y131.904 Z5.84
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 0.874647
G1 F2982.226
M204 S6000
G1 X134.372 Y132.389 E.12976
; LINE_WIDTH: 0.897056
G1 F2896.205
G1 X134.558 Y132.513 E.03954
; LINE_WIDTH: 0.941873
G1 F2738.238
G1 X134.743 Y132.637 E.04182
; LINE_WIDTH: 0.986691
G1 F2596.612
G1 X134.929 Y132.76 E.0441
; LINE_WIDTH: 1.03151
G1 F2468.916
G1 X135.114 Y132.884 E.04638
G1 X135.009 Y132.721 E.04039
; LINE_WIDTH: 0.986691
G1 F2596.612
G1 X134.904 Y132.557 E.0384
; LINE_WIDTH: 0.941873
G1 F2738.238
G1 X134.799 Y132.394 E.03642
; LINE_WIDTH: 0.877313
G1 F2971.723
G2 X134.3 Y131.654 I-12.797 J8.092 E.15423
G1 X133.943 Y131.006 E.12777
; LINE_WIDTH: 0.860985
G1 F3037.226
G1 X133.812 Y130.672 E.06064
; LINE_WIDTH: 0.821318
G1 F3209.056
G3 X133.271 Y128.234 I6.451 J-2.71 E.40175
G3 X133.349 Y127.04 I4.319 J-.319 E.192
; LINE_WIDTH: 0.843294
G1 F3111.531
G1 X133.335 Y126.967 E.01213
; LINE_WIDTH: 0.889887
G1 F2923.179
G1 X133.321 Y126.895 E.01291
; LINE_WIDTH: 0.93648
G1 F2756.328
G1 X133.307 Y126.823 E.0137
; LINE_WIDTH: 0.983074
G1 F2607.497
G1 X133.293 Y126.751 E.01448
; LINE_WIDTH: 1.02967
G1 F2473.914
G1 X133.279 Y126.679 E.01526
; LINE_WIDTH: 1.08083
G1 F2342.145
G1 X133.265 Y126.606 E.01612
G1 X133.538 Y125.703 E.20685
G1 X133.854 Y124.942 E.18065
G3 X134.595 Y123.728 I13.33 J7.309 E.31191
G1 X135.142 Y123.088 E.18442
G3 X133.996 Y124.055 I-27.562 J-31.503 E.3286
G1 X133.396 Y124.644 E.18429
G1 X132.831 Y125.368 E.20122
G1 X132.394 Y126.162 E.19874
G1 X132.318 Y126.383 E.05134
; LINE_WIDTH: 1.07849
G1 F2347.881
G1 X132.272 Y126.446 E.01702
; LINE_WIDTH: 1.03149
G1 F2468.967
G1 X132.227 Y126.51 E.01619
; LINE_WIDTH: 0.984491
G1 F2603.22
G1 X132.182 Y126.573 E.01535
; LINE_WIDTH: 0.937493
G1 F2752.914
G1 X132.136 Y126.636 E.01452
; LINE_WIDTH: 0.890495
G1 F2920.874
G1 X132.091 Y126.7 E.01368
; LINE_WIDTH: 0.822959
G1 F3201.562
G1 X132.046 Y126.763 E.01248
G2 X131.873 Y127.843 I7.2 J1.709 E.17551
G1 X131.91 Y128.621 E.12484
G1 X132.02 Y129.195 E.09376
G1 X132.272 Y129.89 E.11856
G1 X132.719 Y130.697 E.14794
G1 X133.147 Y131.221 E.10858
; LINE_WIDTH: 0.865942
G1 F3017.036
G1 X133.713 Y131.817 E.13967
M204 S10000
G1 X132.677 Y129.067 F42000
; LINE_WIDTH: 0.790989
G1 F3354.144
M204 S6000
G1 X132.593 Y128.543 E.08119
G1 X132.566 Y127.843 E.10722
G1 X132.659 Y127.081 E.1175
; LINE_WIDTH: 0.766317
G1 F3482.217
G1 X132.662 Y127.069 E.00178
M204 S10000
G1 X136.118 Y133.776 F42000
; LINE_WIDTH: 0.974752
G1 F2632.888
M204 S6000
G1 X135.66 Y133.372 E.11912
; LINE_WIDTH: 1.01594
G1 F2511.82
G1 X135.202 Y132.968 E.12486
; LINE_WIDTH: 1.04523
G1 F2432.301
G1 X135.201 Y132.967 E.00025
; WIPE_START
G1 X135.202 Y132.968 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.07 Y134.195 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.26558
G1 F1964.379
M204 S6000
G1 X141.926 Y134.195 E.03741
G1 X141.855 Y134.319 E.03742
G1 X141.926 Y134.443 E.03742
G1 X142.07 Y134.443 E.03742
G1 X142.081 Y134.423 E.00606
M204 S10000
G1 X142.914 Y134.442 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.859301
G1 F3000
M204 S6000
G1 X143.183 Y134.493 E.04617
; LINE_WIDTH: 0.827192
G1 X143.452 Y134.545 E.04416
; LINE_WIDTH: 0.808903
G1 X143.464 Y134.547 E.00196
; LINE_WIDTH: 0.782171
G1 X143.604 Y134.572 E.02156
; LINE_WIDTH: 0.733216
G1 X143.745 Y134.596 E.01996
; LINE_WIDTH: 0.68426
G1 X143.886 Y134.621 E.01837
; LINE_WIDTH: 0.635305
G1 X144.026 Y134.645 E.01677
; LINE_WIDTH: 0.58635
G1 X144.167 Y134.67 E.01518
; LINE_WIDTH: 0.537395
G1 X144.307 Y134.694 E.01359
; LINE_WIDTH: 0.489245
G1 X144.457 Y134.718 E.01273
; LINE_WIDTH: 0.443094
G1 X144.6 Y134.741 E.01067
; LINE_WIDTH: 0.397926
G1 X144.743 Y134.763 E.00918
; LINE_WIDTH: 0.352758
G1 X144.886 Y134.786 E.00769
; LINE_WIDTH: 0.307589
G1 X145.029 Y134.808 E.00619
; LINE_WIDTH: 0.262421
G1 X145.172 Y134.831 E.0047
; LINE_WIDTH: 0.229112
G1 X145.294 Y134.849 E.00307
; WIPE_START
G1 X145.172 Y134.831 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.119 Y135.534 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 0.249466
G1 F3000
M204 S6000
G1 X147.4 Y135.126 E.01462
; LINE_WIDTH: 0.281927
G1 X147.681 Y134.718 E.01829
; WIPE_START
G1 X147.4 Y135.126 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.578 Y127.496 Z5.84 F42000
G1 X147.724 Y121.237 Z5.84
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 0.590894
G1 F3000
M204 S6000
G1 X147.439 Y121.09 E.03439
G1 X147.43 Y121.059 E.00353
; LINE_WIDTH: 0.573642
G1 X147.395 Y120.95 E.01181
; LINE_WIDTH: 0.5296
G1 X147.362 Y120.87 E.0081
; LINE_WIDTH: 0.486345
G1 X147.333 Y120.807 E.00577
; LINE_WIDTH: 0.444448
G1 X147.171 Y120.491 E.02632
; WIPE_START
G1 X147.333 Y120.807 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.299 Y121.152 Z5.84 F42000
G1 Z5.44
G1 E.8 F1800
; LINE_WIDTH: 0.23886
G1 F3000
M204 S6000
G1 X145.157 Y121.173 E.0039
; LINE_WIDTH: 0.279401
G1 X145.014 Y121.195 E.00523
; LINE_WIDTH: 0.319943
G1 X144.872 Y121.217 E.00656
; LINE_WIDTH: 0.360485
G1 X144.73 Y121.239 E.00789
; LINE_WIDTH: 0.401705
G1 X144.583 Y121.261 E.00955
; LINE_WIDTH: 0.447025
G1 X144.44 Y121.285 E.01082
; LINE_WIDTH: 0.49542
G1 X144.297 Y121.309 E.01242
; LINE_WIDTH: 0.543815
G1 X144.154 Y121.334 E.01403
; LINE_WIDTH: 0.59221
G1 X144.011 Y121.358 E.01563
; LINE_WIDTH: 0.640605
G1 X143.868 Y121.382 E.01723
; LINE_WIDTH: 0.689
G1 X143.725 Y121.406 E.01883
; LINE_WIDTH: 0.714756
G1 X143.716 Y121.408 E.00122
; LINE_WIDTH: 0.736413
G1 X143.514 Y121.445 E.02888
; LINE_WIDTH: 0.776603
G1 X143.312 Y121.482 E.03077
; LINE_WIDTH: 0.816792
G1 X143.11 Y121.52 E.03265
; LINE_WIDTH: 0.856982
G1 X142.908 Y121.557 E.03453
M204 S10000
G1 X142.065 Y121.556 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2635
G1 F1967.953
M204 S6000
G1 X141.922 Y121.556 E.03728
G1 X141.85 Y121.68 E.03728
G1 X141.922 Y121.804 E.03728
G1 X142.065 Y121.804 E.03728
G1 X142.076 Y121.784 E.00597
; CHANGE_LAYER
; Z_HEIGHT: 6
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F1967.953
G1 X142.065 Y121.804 E-.02927
G1 X141.922 Y121.804 E-.18269
G1 X141.85 Y121.68 E-.18268
G1 X141.922 Y121.556 E-.18269
G1 X142.065 Y121.556 E-.18267
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 11/51
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z6 I-1.088 J-1.311 P1  F42000
G1 X133.041 Y129.043 Z6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X133.075 Y129.22 E.02874
G2 X133.835 Y130.978 I5.213 J-1.21 E.30759
G2 X135.132 Y132.483 I6.467 J-4.26 E.31805
G1 X138.22 Y135.026 E.6388
G1 X140.182 Y133.114 E.4374
G2 X145.124 Y134.876 I10.975 J-22.973 E.83916
G1 X145.075 Y135.241 E.05872
G1 X124.744 Y135.241 E3.24635
G2 X122.779 Y135.74 I.033 J4.248 E.32695
G3 X109.513 Y124.044 I-4.954 J-7.753 E3.79354
G3 X122.78 Y120.261 I8.313 J3.998 E2.48837
G2 X124.737 Y120.76 I1.997 J-3.75 E.32563
G1 X145.076 Y120.76 E3.2475
G1 X145.122 Y121.127 E.05912
G2 X140.192 Y122.877 I6.529 J26.223 E.83664
G1 X138.231 Y120.955 E.43844
G1 X135.204 Y123.456 E.62701
G2 X133.376 Y125.885 I4.586 J5.353 E.48922
G2 X132.992 Y128.783 I4.911 J2.125 E.4728
G1 X133.019 Y128.925 E.023
M204 S10000
G1 X133.813 Y129.242 F42000
G1 F3215.099
M204 S6000
G1 X133.901 Y129.552 E.05144
G2 X134.427 Y130.604 I4.399 J-1.543 E.18823
G2 X135.6 Y131.963 I5.825 J-3.844 E.28756
G1 X138.181 Y134.087 E.53369
G1 X140.055 Y132.261 E.41779
G2 X144.409 Y133.958 I10.106 J-19.502 E.74748
G2 X148.099 Y134.809 I13.719 J-51.04 E.60484
G3 X147.169 Y135.884 I-1.41 J-.28 E.23733
G3 X146.777 Y135.94 I-.392 J-1.325 E.06352
G1 X124.754 Y135.94 E3.5165
G2 X123.11 Y136.357 I.023 J3.543 E.27348
G3 X117.979 Y118.113 I-5.296 J-8.354 E5.88054
G3 X123.11 Y119.644 I-.196 J10.021 E.86554
G2 X124.75 Y120.06 I1.666 J-3.127 E.27269
G1 X146.776 Y120.06 E3.51711
G3 X148.014 Y120.94 I.014 J1.291 E.25927
G1 X148.099 Y121.195 E.04291
G2 X141.977 Y122.856 I5.891 J33.82 E1.01438
G2 X140.068 Y123.735 I6.793 J17.265 E.33574
G1 X138.191 Y121.895 E.41967
G1 X135.669 Y123.979 E.5223
G2 X133.898 Y126.474 I4.004 J4.72 E.49361
G2 X133.758 Y129.062 I4.402 J1.535 E.41939
G1 X133.778 Y129.127 E.01094
; WIPE_START
G1 X133.901 Y129.552 E-.16803
G1 X134.037 Y129.882 E-.13549
G1 X134.177 Y130.174 E-.12327
G1 X134.427 Y130.604 E-.18876
G1 X134.625 Y130.892 E-.1331
G1 X134.644 Y130.916 E-.01136
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.373 Y128.08 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X137.38 Y128.239 E.02531
G2 X137.896 Y129.599 I2.649 J-.227 E.23531
G2 X139.613 Y131.184 I4.912 J-3.598 E.37551
G2 X143.232 Y132.859 I8.599 J-13.832 E.63838
G2 X148.782 Y134.216 I11.609 J-35.457 E.9132
G3 X148.661 Y135.335 I-2.844 J.257 E.18089
G3 X146.786 Y136.64 I-1.873 J-.691 E.38826
G1 X124.763 Y136.64 E3.51654
G2 X123.44 Y136.974 I.012 J2.839 E.22003
G3 X118.001 Y117.414 I-5.627 J-8.972 E6.28993
G3 X123.44 Y119.027 I-.222 J10.723 E.9168
G2 X124.762 Y119.36 I1.335 J-2.506 E.21973
G1 X146.786 Y119.36 E3.51677
G3 X148.782 Y121.356 I.004 J1.992 E.50093
G1 X148.782 Y121.785 E.06841
G2 X142.232 Y123.508 I5.393 J33.815 E1.08329
G2 X139.004 Y125.254 I4.504 J12.182 E.58791
G2 X137.616 Y126.893 I2.857 J3.826 E.34596
G2 X137.373 Y127.88 I2.412 J1.118 E.16323
G1 X137.373 Y127.96 E.01282
; WIPE_START
M204 S6000
G1 X137.38 Y128.239 E-.1058
G1 X137.455 Y128.666 E-.16496
G1 X137.526 Y128.886 E-.08775
G1 X137.715 Y129.301 E-.17345
G1 X137.896 Y129.599 E-.13231
G1 X138.052 Y129.796 E-.09572
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


G1 X140.345 Y134.193 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.26968
G1 F1957.373
M204 S6000
G1 X140.201 Y134.193 E.03768
G1 X140.129 Y134.317 E.03768
G1 X140.201 Y134.442 E.03768
G1 X140.345 Y134.442 E.03768
G1 X140.356 Y134.421 E.00621
M204 S10000
G1 X141.19 Y134.442 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.859172
G1 F3000
M204 S6000
G1 X141.46 Y134.494 E.04635
; LINE_WIDTH: 0.826629
G1 X141.73 Y134.546 E.04431
; LINE_WIDTH: 0.80807
G1 X141.743 Y134.548 E.00198
; LINE_WIDTH: 0.780849
G1 X141.886 Y134.573 E.02195
; LINE_WIDTH: 0.73096
G1 X142.03 Y134.598 E.02029
; LINE_WIDTH: 0.68107
G1 X142.173 Y134.623 E.01863
; LINE_WIDTH: 0.631181
G1 X142.317 Y134.648 E.01698
; LINE_WIDTH: 0.581291
M73 P50 R9
G1 X142.46 Y134.673 E.01532
; LINE_WIDTH: 0.531402
G1 X142.604 Y134.698 E.01366
; LINE_WIDTH: 0.481553
G1 X142.77 Y134.724 E.0139
; LINE_WIDTH: 0.43314
G1 X142.93 Y134.749 E.01156
; LINE_WIDTH: 0.385713
G1 X143.09 Y134.774 E.00981
; LINE_WIDTH: 0.338285
G1 X143.25 Y134.799 E.00806
; LINE_WIDTH: 0.290858
G1 X143.41 Y134.824 E.00631
; LINE_WIDTH: 0.243431
G1 X143.57 Y134.849 E.00455
; WIPE_START
G1 X143.41 Y134.824 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.447 Y135.1 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.981725
G1 F2611.579
M204 S6000
G1 X146.016 Y135.168 E.11272
; LINE_WIDTH: 0.944702
G1 F2728.844
G1 X146.21 Y135.189 E.03671
; LINE_WIDTH: 0.903957
G1 F2870.703
G1 X146.394 Y135.209 E.0331
; LINE_WIDTH: 0.864293
G1 F3000
G1 X146.579 Y135.228 E.03143
; LINE_WIDTH: 0.824629
G1 X146.763 Y135.248 E.02975
; LINE_WIDTH: 0.791191
G1 X146.864 Y135.256 E.01553
; LINE_WIDTH: 0.764504
G1 X146.932 Y135.258 E.01006
; LINE_WIDTH: 0.732975
G1 X147.007 Y135.255 E.0105
; LINE_WIDTH: 0.691741
G1 X147.086 Y135.247 E.01032
; LINE_WIDTH: 0.653264
G1 X147.129 Y135.24 E.00538
; LINE_WIDTH: 0.622494
G1 X147.173 Y135.233 E.00507
; LINE_WIDTH: 0.586172
G1 X147.592 Y135.143 E.04554
; WIPE_START
G1 X147.173 Y135.233 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.567 Y129.147 Z6.4 F42000
G1 X139.231 Y124.741 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828017
G1 F3178.684
M204 S2000
G1 X137.625 Y123.135 E.36676
G1 X137.077 Y123.588 E.11483
G1 X138.439 Y124.95 E.31108
G2 X137.923 Y125.435 I8.863 J9.937 E.11439
G1 X136.529 Y124.041 E.31845
G2 X135.987 Y124.499 I2.857 J3.929 E.11482
G1 X137.467 Y125.98 E.33809
G2 X137.094 Y126.608 I3.99 J2.793 E.11809
G1 X135.481 Y124.997 E.36817
G2 X135.039 Y125.554 I6.211 J5.374 E.11489
G1 X136.84 Y127.355 E.41136
G2 X136.784 Y128.3 I2.99 J.652 E.15348
G1 X134.665 Y126.181 E.48396
G2 X134.383 Y126.9 I5.109 J2.418 E.12485
G1 X139.477 Y131.994 E1.16337
G1 X138.97 Y132.488 E.11433
G1 X134.234 Y127.752 E1.08174
G1 X134.231 Y127.778 E.00427
G2 X134.321 Y128.84 I4.075 J.189 E.17263
G1 X138.463 Y132.982 E.946
G1 X138.148 Y133.289 E.07111
G1 X136.007 Y131.527 E.44784
G1 X134.334 Y129.854 E.38212
; WIPE_START
M204 S6000
G1 X135.748 Y131.268 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.118 Y134.544 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.114
M204 S6000
G1 X136.532 Y134.543 E.38558
G1 X134.674 Y133.013 E.38441
G1 X134.028 Y132.369 E.14559
G1 X133.263 Y131.38 E.19973
G1 X132.824 Y130.575 E.14629
G1 X132.441 Y129.521 E.17906
G3 X132.238 Y128.355 I13.248 J-2.907 E.18918
G1 X132.236 Y127.694 E.10553
G1 X132.383 Y126.68 E.1635
G3 X132.883 Y125.299 I9.471 J2.649 E.23472
G3 X133.996 Y123.664 I8.204 J4.388 E.31645
G1 X134.724 Y122.946 E.16333
G3 X136.525 Y121.456 I119.979 J143.17 E.37314
G1 X134.113 Y121.456 E.38514
G1 X131.695 Y123.454 E.5008
G1 X131.065 Y124.075 E.14126
G1 X130.451 Y124.843 E.1571
G1 X129.989 Y125.633 E.14611
G1 X129.606 Y126.697 E.1806
G1 X129.453 Y127.503 E.1309
G1 X129.453 Y128.516 E.16187
G1 X129.639 Y129.468 E.15489
G1 X130.075 Y130.521 E.18184
G1 X130.557 Y131.3 E.14633
G1 X130.997 Y131.854 E.11293
G1 X131.638 Y132.497 E.14502
G1 X134.025 Y134.467 E.49421
; WIPE_START
G1 X132.482 Y133.194 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.158 Y125.592 Z6.4 F42000
G1 X133.377 Y123.126 Z6.4
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 1.03464
G1 F2460.455
M204 S6000
G1 X133.781 Y122.761 E.11358
; LINE_WIDTH: 0.986052
G1 F2598.527
G1 X134.185 Y122.396 E.10754
; LINE_WIDTH: 0.959727
G1 F2680.007
G1 X134.297 Y122.302 E.02818
M204 S10000
G1 X131.228 Y130.829 F42000
; LINE_WIDTH: 1.05736
G1 F2400.819
M204 S6000
G1 X131.609 Y131.309 E.1312
G1 X132.189 Y131.892 E.17579
G2 X133.379 Y132.871 I250.095 J-302.827 E.32958
G1 X132.616 Y131.88 E.26747
G1 X132.104 Y130.963 E.22461
G3 X131.568 Y129.479 I14.82 J-6.189 E.3375
; LINE_WIDTH: 1.05972
G1 F2394.772
G1 X131.577 Y129.394 E.01837
; LINE_WIDTH: 1.01614
G1 F2511.273
G1 X131.586 Y129.309 E.01751
; LINE_WIDTH: 0.97255
G1 F2639.688
G1 X131.595 Y129.223 E.01666
; LINE_WIDTH: 0.928964
G1 F2781.945
G1 X131.604 Y129.138 E.01581
; LINE_WIDTH: 0.885377
G1 F2940.408
G1 X131.613 Y129.053 E.01496
; LINE_WIDTH: 0.820978
G1 F3210.612
G1 X131.621 Y128.968 E.0137
G3 X131.604 Y127.16 I5.385 J-.956 E.29039
; LINE_WIDTH: 0.84345
G1 F3110.859
G1 X131.598 Y127.04 E.01981
; LINE_WIDTH: 0.890356
G1 F2921.399
G1 X131.592 Y126.92 E.0211
; LINE_WIDTH: 0.937262
G1 F2753.692
G1 X131.586 Y126.8 E.02238
; LINE_WIDTH: 0.984168
G1 F2604.194
G1 X131.58 Y126.68 E.02367
; LINE_WIDTH: 1.03107
G1 F2470.093
G1 X131.574 Y126.561 E.02495
; LINE_WIDTH: 1.06767
G1 F2374.686
G1 X131.845 Y125.664 E.20236
G1 X132.141 Y124.939 E.16935
G3 X133.359 Y123.144 I8.699 J4.596 E.46992
G1 X133.377 Y123.126 E.00551
G3 X132.249 Y124.067 I-61.009 J-72.098 E.31758
G1 X131.679 Y124.628 E.17291
G1 X131.133 Y125.311 E.18907
G1 X130.74 Y125.984 E.16848
G1 X130.611 Y126.318 E.07741
; LINE_WIDTH: 1.03107
G1 F2470.093
G1 X130.549 Y126.421 E.02495
; LINE_WIDTH: 0.984168
G1 F2604.194
G1 X130.487 Y126.524 E.02367
; LINE_WIDTH: 0.937262
G1 F2753.692
G1 X130.425 Y126.627 E.02238
; LINE_WIDTH: 0.890356
G1 F2921.399
G1 X130.363 Y126.729 E.0211
; LINE_WIDTH: 0.821061
G1 F3210.233
G1 X130.301 Y126.832 E.0192
G1 X130.165 Y127.504 E.10968
G1 X130.153 Y128.352 E.13557
G1 X130.3 Y129.2 E.13757
G1 X130.338 Y129.327 E.02128
; LINE_WIDTH: 0.84179
G1 F3118.013
G1 X130.39 Y129.395 E.01411
; LINE_WIDTH: 0.885377
G1 F2940.408
G1 X130.442 Y129.463 E.01496
; LINE_WIDTH: 0.928964
G1 F2781.945
G1 X130.494 Y129.532 E.01581
; LINE_WIDTH: 0.97255
G1 F2639.688
G1 X130.546 Y129.6 E.01666
; LINE_WIDTH: 1.01614
G1 F2511.273
G1 X130.597 Y129.668 E.01751
; LINE_WIDTH: 1.06122
G1 F2390.97
G1 X130.649 Y129.736 E.0184
G1 X130.825 Y130.179 E.10222
G1 X131.164 Y130.727 E.13837
M204 S10000
G1 X130.958 Y129.07 F42000
; LINE_WIDTH: 0.79271
G1 F3345.561
M204 S6000
G1 X130.845 Y128.381 E.10721
G1 X130.844 Y127.698 E.10488
G1 X130.919 Y127.18 E.08023
M204 S10000
G1 X134.393 Y133.776 F42000
; LINE_WIDTH: 0.975662
G1 F2630.087
M204 S6000
G1 X133.941 Y133.376 E.11784
; LINE_WIDTH: 1.01643
G1 F2510.446
G1 X133.488 Y132.977 E.12346
; LINE_WIDTH: 1.04875
G1 F2423.081
G1 X133.466 Y132.954 E.00673
; WIPE_START
G1 X133.488 Y132.977 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.416 Y126.432 Z6.4 F42000
G1 X140.344 Y121.552 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25246
G1 F1987.141
M204 S6000
G1 X140.203 Y121.552 E.03656
G1 X140.132 Y121.674 E.03656
G1 X140.203 Y121.797 E.03656
G1 X140.344 Y121.797 E.03656
G1 X140.355 Y121.778 E.00556
M204 S10000
G1 X141.183 Y121.557 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.858194
G1 F3000
M204 S6000
G1 X141.379 Y121.521 E.03348
; LINE_WIDTH: 0.820387
G1 X141.574 Y121.485 E.03177
; LINE_WIDTH: 0.782581
G1 X141.77 Y121.449 E.03005
; LINE_WIDTH: 0.744774
G1 X141.966 Y121.413 E.02834
; LINE_WIDTH: 0.724334
G1 X141.974 Y121.411 E.00122
; LINE_WIDTH: 0.698142
G1 X142.12 Y121.386 E.01944
; LINE_WIDTH: 0.64887
G1 X142.265 Y121.362 E.01778
; LINE_WIDTH: 0.599599
G1 X142.41 Y121.337 E.01612
; LINE_WIDTH: 0.550328
G1 X142.556 Y121.313 E.01447
; LINE_WIDTH: 0.501057
G1 X142.701 Y121.288 E.01281
; LINE_WIDTH: 0.451787
G1 X142.846 Y121.263 E.01115
; LINE_WIDTH: 0.405579
G1 X142.996 Y121.24 E.00987
; LINE_WIDTH: 0.363475
G1 X143.141 Y121.218 E.00814
; LINE_WIDTH: 0.322074
G1 X143.286 Y121.196 E.00675
; LINE_WIDTH: 0.280672
G1 X143.431 Y121.174 E.00537
; LINE_WIDTH: 0.239271
G1 X143.576 Y121.152 E.00398
; WIPE_START
G1 X143.431 Y121.174 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.446 Y120.899 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; LINE_WIDTH: 0.976412
G1 F2627.785
M204 S6000
G1 X145.783 Y120.861 E.06624
; LINE_WIDTH: 0.932714
G1 F2769.106
G1 X146.12 Y120.823 E.06286
; LINE_WIDTH: 0.889016
G1 F2926.492
G1 X146.457 Y120.785 E.05948
; LINE_WIDTH: 0.848176
G1 F3000
G1 X146.642 Y120.766 E.03099
; LINE_WIDTH: 0.811357
G1 X146.819 Y120.748 E.02797
; LINE_WIDTH: 0.77626
G3 X146.929 Y120.745 I.096 J1.159 E.01645
; LINE_WIDTH: 0.7377
G1 X147.009 Y120.748 E.01135
; LINE_WIDTH: 0.696816
G1 X147.553 Y120.802 E.07186
; WIPE_START
G1 X147.009 Y120.748 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.378 Y120.908 Z6.4 F42000
G1 X112.209 Y121.479 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.42 Y123.616 I5.811 J6.686 E.44684
G1 X122.193 Y135.389 E2.6586
G3 X119.599 Y136.401 I-4.777 J-8.411 E.44623
G1 X128.794 Y127.206 E2.07639
G2 X128.794 Y128.794 I7.388 J.795 E.25394
G1 X119.6 Y119.6 E2.07605
G3 X122.192 Y120.612 I-2.169 J9.385 E.44591
G1 X110.421 Y132.383 E2.65819
G2 X112.209 Y134.521 I8.293 J-5.121 E.44647
; CHANGE_LAYER
; Z_HEIGHT: 6.56
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.18 Y133.472 E-.55832
G1 X110.876 Y133.036 E-.20168
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 12/51
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z6.56 I.258 J1.684 P1  F42000
G1 X131.558 Y129.865 Z6.56
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.681 Y130.187 E.05508
G2 X133.395 Y132.472 I6.503 J-3.092 E.45915
G1 X136.513 Y135.041 E.64507
G1 X138.468 Y133.119 E.43774
G2 X143.4 Y134.876 I10.979 J-23.014 E.83747
G1 X143.351 Y135.241 E.05869
G1 X124.744 Y135.241 E2.97101
G2 X122.779 Y135.74 I.033 J4.247 E.32701
G3 X111.047 Y121.775 I-4.955 J-7.747 E4.23234
G3 X122.78 Y120.261 I6.774 J6.277 E2.05017
G2 X124.737 Y120.76 I1.997 J-3.75 E.32559
G1 X143.353 Y120.76 E2.97255
G1 X143.399 Y121.128 E.0592
G2 X138.464 Y122.878 I6.255 J25.47 E.83751
G1 X136.5 Y120.961 E.43827
G1 X133.461 Y123.473 E.62968
G2 X131.678 Y125.824 I4.727 J5.437 E.47442
G2 X131.263 Y128.754 I4.985 J2.2 E.47861
G1 X131.399 Y129.446 E.11258
G1 X131.515 Y129.753 E.05235
M204 S10000
G1 X132.216 Y129.625 F42000
G1 F3215.099
M204 S6000
G1 X132.321 Y129.907 E.04818
G2 X132.68 Y130.563 I4.25 J-1.903 E.11944
G2 X133.866 Y131.953 I5.938 J-3.862 E.29257
G1 X136.472 Y134.1 E.53917
G1 X138.339 Y132.264 E.41811
G2 X142.643 Y133.945 I10.071 J-19.435 E.73922
G2 X148.065 Y135.087 I11.611 J-41.686 E.88539
G3 X147.446 Y135.762 I-1.771 J-1.004 E.14744
G3 X146.777 Y135.94 I-.663 J-1.14 E.11194
G1 X124.754 Y135.94 E3.5165
G2 X123.109 Y136.357 I.022 J3.543 E.27353
G3 X117.989 Y118.113 I-5.296 J-8.354 E5.88209
G3 X123.11 Y119.644 I-.206 J10.02 E.86392
G2 X124.749 Y120.06 I1.666 J-3.127 E.27266
G1 X146.776 Y120.06 E3.51712
G3 X147.821 Y120.573 I.002 J1.317 E.19247
G1 X148.055 Y120.916 E.06643
G2 X140.685 Y122.691 I5.045 J37.141 E1.21251
G2 X138.342 Y123.737 I6.387 J17.459 E.41007
G1 X136.461 Y121.901 E.41969
G1 X133.926 Y123.996 E.52517
G2 X132.32 Y126.104 I4.248 J4.904 E.42615
G2 X132.084 Y129.25 I4.252 J1.9 E.51392
G1 X132.176 Y129.511 E.04423
; WIPE_START
G1 X132.321 Y129.907 E-.16025
G1 X132.47 Y130.203 E-.12559
G1 X132.68 Y130.563 E-.15849
G1 X132.915 Y130.908 E-.15875
G1 X133.171 Y131.232 E-.1569
G1 X133.171 Y131.232 E-.00002
; WIPE_END
G1 E-.04 F1800
M204 S10000
M73 P51 R9
G1 X135.665 Y128.321 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X135.671 Y128.366 E.00718
G2 X136.126 Y129.527 I2.652 J-.368 E.20109
G2 X137.899 Y131.191 I4.905 J-3.453 E.39091
G2 X141.525 Y132.865 I8.895 J-14.501 E.63918
G2 X148.782 Y134.482 I12.388 J-38.502 E1.1889
G3 X146.786 Y136.64 I-2.002 J.151 E.52669
G1 X124.763 Y136.64 E3.5165
G2 X123.44 Y136.974 I.012 J2.839 E.22007
G3 X118.011 Y117.414 I-5.627 J-8.972 E6.2915
G3 X123.44 Y119.027 I-.231 J10.722 E.91517
G2 X124.762 Y119.36 I1.335 J-2.505 E.21974
G1 X146.786 Y119.36 E3.51679
G3 X148.782 Y121.518 I-.007 J2.008 E.5266
G2 X141.711 Y123.073 I5.142 J40.244 E1.15769
G2 X137.987 Y124.753 I5.403 J16.944 E.65364
G2 X136.169 Y126.406 I3.342 J5.502 E.39486
G2 X135.651 Y128.167 I2.153 J1.591 E.29906
G1 X135.654 Y128.202 E.00558
; WIPE_START
M204 S6000
G1 X135.671 Y128.366 E-.06269
G1 X135.752 Y128.737 E-.14448
G1 X135.881 Y129.08 E-.13935
G1 X136.126 Y129.527 E-.19373
G1 X136.475 Y129.989 E-.21976
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


G1 X136.226 Y133.535 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.827557
G1 F3180.752
M204 S2000
G1 X137.881 Y131.88 E.37782
G3 X137.279 Y131.482 I3.329 J-5.695 E.11659
G1 X135.901 Y132.86 E.31443
G1 X135.353 Y132.408 E.1147
G1 X136.714 Y131.047 E.31066
G3 X136.197 Y130.563 I4.34 J-5.149 E.11428
G1 X134.804 Y131.956 E.31796
G1 X134.257 Y131.503 E.11468
G1 X135.741 Y130.018 E.33887
G3 X135.37 Y129.389 I4.164 J-2.884 E.11799
G1 X133.757 Y131.002 E.36813
G3 X133.314 Y130.445 I7.303 J-6.253 E.11495
G1 X135.118 Y128.641 E.41168
G3 X135.064 Y127.694 I2.72 J-.628 E.15385
G1 X132.942 Y129.816 E.48442
G3 X132.654 Y129.104 I3.587 J-1.867 E.12417
G1 X137.759 Y123.999 E1.16527
G1 X137.253 Y123.505 E.11418
G1 X132.51 Y128.248 E1.08263
G3 X132.599 Y127.158 I3.885 J-.229 E.17711
G1 X136.747 Y123.011 E.94663
G1 X136.428 Y122.7 E.07181
G1 X134.322 Y124.441 E.44103
G2 X132.61 Y126.146 I38.805 J40.66 E.39003
; WIPE_START
M204 S6000
G1 X134.027 Y124.735 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.587 Y122.161 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.81716
G1 F3228.198
M204 S6000
G1 X138.523 Y122.032 E.02282
; LINE_WIDTH: 0.851127
G1 F3078.186
G1 X138.459 Y121.904 E.02393
; LINE_WIDTH: 0.885094
G1 F2941.497
G1 X138.395 Y121.775 E.02505
; LINE_WIDTH: 0.923051
G1 F2802.432
G1 X138.394 Y121.765 E.00197
; LINE_WIDTH: 0.964999
G1 F2663.283
G1 X138.392 Y121.754 E.00207
; LINE_WIDTH: 1.00695
G1 F2537.299
G1 X138.39 Y121.743 E.00218
; LINE_WIDTH: 1.0489
G1 F2422.695
G1 X138.389 Y121.733 E.00228
; LINE_WIDTH: 1.09084
G1 F2317.996
G1 X138.387 Y121.722 E.00238
M204 S10000
G1 X139.55 Y122.005 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.766375
G1 F3000
M204 S6000
G1 X139.805 Y121.537 E.07859
; LINE_WIDTH: 0.82345
G1 X139.818 Y121.512 E.00444
; LINE_WIDTH: 0.859203
G1 X139.831 Y121.488 E.00466
; LINE_WIDTH: 0.853531
G1 X139.959 Y121.465 E.02174
; LINE_WIDTH: 0.8064
G1 X140.087 Y121.441 E.02034
; LINE_WIDTH: 0.759269
G1 X140.215 Y121.418 E.01894
; LINE_WIDTH: 0.712662
G1 X140.349 Y121.395 E.01849
; LINE_WIDTH: 0.668299
G1 X140.476 Y121.373 E.01601
; LINE_WIDTH: 0.625407
G1 X140.602 Y121.352 E.01475
; LINE_WIDTH: 0.582515
G1 X140.728 Y121.33 E.0135
; LINE_WIDTH: 0.539622
G1 X140.854 Y121.309 E.01225
; LINE_WIDTH: 0.49673
G1 X140.98 Y121.287 E.011
; LINE_WIDTH: 0.453838
G1 X141.107 Y121.266 E.00974
; LINE_WIDTH: 0.410287
G1 X141.26 Y121.242 E.01025
; LINE_WIDTH: 0.367135
G1 X141.408 Y121.22 E.00844
; LINE_WIDTH: 0.324707
G1 X141.556 Y121.197 E.00699
; LINE_WIDTH: 0.282279
G1 X141.704 Y121.174 E.00554
; LINE_WIDTH: 0.239851
G1 X141.852 Y121.152 E.00409
; WIPE_START
G1 X141.704 Y121.174 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.723 Y120.898 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.977322
G1 F2624.994
M204 S6000
G1 X144.023 Y120.865 E.05889
; LINE_WIDTH: 0.934572
G1 F2762.787
G1 X144.322 Y120.831 E.05595
; LINE_WIDTH: 0.891822
G1 F2915.848
G1 X144.621 Y120.798 E.05301
; LINE_WIDTH: 0.849072
G1 F3000
G1 X144.92 Y120.764 E.05008
; LINE_WIDTH: 0.804235
G1 X145.154 Y120.741 E.03665
; LINE_WIDTH: 0.758398
G1 X145.379 Y120.719 E.03292
; LINE_WIDTH: 0.713437
G1 X145.604 Y120.696 E.0306
; LINE_WIDTH: 0.668476
G1 X145.829 Y120.674 E.02828
; LINE_WIDTH: 0.623515
G1 X146.054 Y120.652 E.02596
; LINE_WIDTH: 0.578021
G1 X146.316 Y120.629 E.02746
; LINE_WIDTH: 0.532636
G1 X146.572 Y120.607 E.02418
; LINE_WIDTH: 0.487766
G1 X146.828 Y120.584 E.02155
; LINE_WIDTH: 0.435858
G3 X147.334 Y120.584 I.258 J5.706 E.03651
; WIPE_START
G1 X146.828 Y120.584 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.115 Y128.211 Z6.96 F42000
G1 X147.385 Y135.381 Z6.96
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.361769
G1 F3000
M204 S6000
G1 X147.064 Y135.414 E.01779
; LINE_WIDTH: 0.399672
G1 X146.969 Y135.419 E.00612
; LINE_WIDTH: 0.443948
G3 X146.831 Y135.417 I-.042 J-1.612 E.01015
; LINE_WIDTH: 0.480831
G1 X146.636 Y135.4 E.01613
; LINE_WIDTH: 0.514643
G1 X146.441 Y135.383 E.01764
; LINE_WIDTH: 0.548851
G1 X146.241 Y135.366 E.01962
; LINE_WIDTH: 0.589827
G1 X145.997 Y135.343 E.02625
; LINE_WIDTH: 0.637096
G1 X145.753 Y135.319 E.0289
; LINE_WIDTH: 0.684364
G1 X145.509 Y135.296 E.03154
; LINE_WIDTH: 0.732316
G1 X145.258 Y135.271 E.03521
; LINE_WIDTH: 0.777645
G1 X145.065 Y135.251 E.02923
; LINE_WIDTH: 0.819523
G1 X144.871 Y135.23 E.03109
; LINE_WIDTH: 0.861402
G1 X144.677 Y135.209 E.03295
; LINE_WIDTH: 0.903281
G1 F2873.181
G1 X144.483 Y135.188 E.03481
; LINE_WIDTH: 0.94627
G1 F2723.665
G1 X144.28 Y135.166 E.03866
; LINE_WIDTH: 0.983
G1 F2607.719
G1 X143.723 Y135.099 E.11036
; WIPE_START
G1 X144.28 Y135.166 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.846 Y134.849 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 0.242945
G1 F3000
M204 S6000
G1 X141.689 Y134.824 E.00445
; LINE_WIDTH: 0.289402
G1 X141.532 Y134.8 E.00613
; LINE_WIDTH: 0.335858
G1 X141.375 Y134.775 E.00781
; LINE_WIDTH: 0.382315
G1 X141.218 Y134.751 E.0095
; LINE_WIDTH: 0.428771
G1 X141.061 Y134.726 E.01118
; LINE_WIDTH: 0.476189
G1 X140.898 Y134.701 E.01343
; LINE_WIDTH: 0.522254
G1 X140.773 Y134.679 E.01162
; LINE_WIDTH: 0.565609
G1 X140.648 Y134.657 E.01288
; LINE_WIDTH: 0.608964
G1 X140.523 Y134.635 E.01413
; LINE_WIDTH: 0.652319
G1 X140.398 Y134.614 E.01538
; LINE_WIDTH: 0.695674
G1 X140.274 Y134.592 E.01664
; LINE_WIDTH: 0.739029
G1 X140.149 Y134.57 E.01789
; LINE_WIDTH: 0.784522
G1 X140.012 Y134.547 E.02109
; LINE_WIDTH: 0.825255
G1 X139.739 Y134.494 E.04464
; LINE_WIDTH: 0.858691
G1 X139.467 Y134.442 E.04675
M204 S10000
G1 X138.625 Y134.2 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2582
G1 F1977.118
M204 S6000
G1 X138.483 Y134.2 E.03693
G1 X138.412 Y134.323 E.03694
G1 X138.483 Y134.446 E.03693
G1 X138.625 Y134.446 E.03694
G1 X138.636 Y134.427 E.00578
; WIPE_START
G1 X138.625 Y134.446 E-.0286
G1 X138.483 Y134.446 E-.18285
G1 X138.412 Y134.323 E-.18285
G1 X138.483 Y134.2 E-.18286
G1 X138.625 Y134.2 E-.18284
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.808 Y134.543 Z6.96 F42000
G1 Z6.56
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819996
G1 F3215.116
M204 S6000
G1 X132.937 Y133.001 E.38712
G1 X132.314 Y132.383 E.14008
G1 X131.648 Y131.546 E.17086
G1 X131.088 Y130.556 E.1816
G3 X130.712 Y129.578 I10.079 J-4.429 E.16735
G1 X130.52 Y128.42 E.1875
G1 X130.514 Y127.673 E.11924
G3 X130.839 Y126.053 I6.731 J.508 E.26447
G1 X131.152 Y125.322 E.12705
G3 X132.279 Y123.656 I7.66 J3.968 E.32189
G1 X132.981 Y122.963 E.15738
G3 X134.802 Y121.456 I144.935 J173.268 E.37751
G1 X132.409 Y121.455 E.38217
G1 X129.934 Y123.485 E.51117
G1 X129.285 Y124.131 E.14622
G1 X128.732 Y124.835 E.14289
G1 X128.268 Y125.626 E.14638
G1 X127.916 Y126.536 E.15587
G1 X127.732 Y127.488 E.15471
G1 X127.728 Y128.472 E.15718
G1 X127.913 Y129.456 E.15995
G1 X128.257 Y130.354 E.15343
G1 X128.721 Y131.15 E.14717
G1 X129.267 Y131.849 E.1416
G1 X129.898 Y132.483 E.14284
G1 X132.393 Y134.544 E.51671
G1 X134.688 Y134.543 E.3665
; WIPE_START
G1 X132.688 Y134.544 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.009 Y126.942 Z6.96 F42000
G1 X131.668 Y123.117 Z6.96
G1 Z6.56
G1 E.8 F1800
; LINE_WIDTH: 1.02563
G1 F2484.938
M204 S6000
G1 X132.056 Y122.767 E.10796
; LINE_WIDTH: 0.976862
G1 F2626.403
G1 X132.444 Y122.417 E.10215
; LINE_WIDTH: 0.949837
G1 F2711.954
G1 X132.59 Y122.295 E.03588
M204 S10000
G1 X128.469 Y127.361 F42000
; LINE_WIDTH: 0.824846
G1 F3192.989
M204 S6000
G1 X128.431 Y127.672 E.05035
G1 X128.428 Y128.408 E.11832
G1 X128.589 Y129.265 E.1402
G1 X128.884 Y130 E.12733
G1 X128.942 Y130.102 E.01888
; LINE_WIDTH: 0.877384
G1 F2971.445
G1 X129 Y130.162 E.01444
; LINE_WIDTH: 0.918519
G1 F2818.339
G1 X129.059 Y130.221 E.01522
; LINE_WIDTH: 0.959655
G1 F2680.239
G1 X129.117 Y130.281 E.01601
; LINE_WIDTH: 1.00079
G1 F2555.04
G1 X129.176 Y130.341 E.01679
; LINE_WIDTH: 0.996424
G1 F2567.768
G1 X129.409 Y130.725 E.08978
; LINE_WIDTH: 0.946559
G1 F2722.71
M73 P52 R9
G1 X129.641 Y131.109 E.08467
; LINE_WIDTH: 0.894898
G1 F2904.272
G1 X129.836 Y131.378 E.05872
G2 X130.797 Y132.271 I5.04 J-4.456 E.23227
; LINE_WIDTH: 0.913012
G1 F2837.917
G1 X131.009 Y132.419 E.04669
; LINE_WIDTH: 0.955242
G1 F2694.401
G1 X131.22 Y132.566 E.04918
; LINE_WIDTH: 0.997472
G1 F2564.702
G1 X131.432 Y132.714 E.05167
; LINE_WIDTH: 1.0397
G1 F2446.916
G1 X131.644 Y132.862 E.05416
G1 X131.501 Y132.647 E.05416
; LINE_WIDTH: 0.997472
G1 F2564.702
G1 X131.358 Y132.432 E.05167
; LINE_WIDTH: 0.955242
G1 F2694.401
G1 X131.215 Y132.217 E.04918
; LINE_WIDTH: 0.895504
G1 F2902.001
G1 X131.072 Y132.002 E.04566
G1 X130.446 Y130.917 E.22163
; LINE_WIDTH: 0.916287
G1 F2826.243
G1 X130.293 Y130.613 E.06181
; LINE_WIDTH: 0.965067
G1 F2663.069
G1 X130.139 Y130.309 E.0656
; LINE_WIDTH: 1.00541
G1 F2541.713
G1 X129.986 Y129.953 E.07836
; LINE_WIDTH: 0.999366
G1 F2559.177
G1 X129.992 Y129.888 E.013
; LINE_WIDTH: 0.955383
G1 F2693.946
G1 X129.998 Y129.824 E.01234
; LINE_WIDTH: 0.911401
G1 F2843.696
G1 X130.003 Y129.759 E.0117
; LINE_WIDTH: 0.867418
G1 F3011.076
G1 X130.009 Y129.695 E.01104
; LINE_WIDTH: 0.823582
G1 F3198.727
G3 X129.815 Y128.364 I125.547 J-18.957 E.21583
G3 X129.867 Y127.117 I6.458 J-.357 E.20068
; LINE_WIDTH: 0.841894
G1 F3117.567
G1 X129.865 Y127.011 E.01743
; LINE_WIDTH: 0.885687
G1 F2939.217
G1 X129.862 Y126.905 E.01849
; LINE_WIDTH: 0.92948
G1 F2780.169
G1 X129.86 Y126.799 E.01955
; LINE_WIDTH: 0.973274
G1 F2637.45
G1 X129.857 Y126.693 E.0206
; LINE_WIDTH: 1.01707
G1 F2508.669
G1 X129.854 Y126.587 E.02166
; LINE_WIDTH: 1.04636
G1 F2429.318
G1 X129.852 Y126.482 E.02237
G1 X130.079 Y125.829 E.14602
; LINE_WIDTH: 0.990987
G1 F2583.802
G1 X130.433 Y125.011 E.17712
G3 X131.113 Y123.863 I11.13 J5.812 E.26526
; LINE_WIDTH: 1.0017
G1 F2552.402
G1 X131.381 Y123.503 E.09014
; LINE_WIDTH: 1.03158
G1 F2468.713
G2 X131.668 Y123.117 I-7.994 J-6.242 E.10015
; LINE_WIDTH: 1.03435
G1 F2461.243
G1 X131.35 Y123.357 E.08313
; LINE_WIDTH: 0.989607
G1 F2587.903
G2 X129.871 Y124.653 I6.725 J9.169 E.39051
G1 X129.381 Y125.277 E.1575
; LINE_WIDTH: 1.00812
G1 F2533.948
G1 X129.207 Y125.615 E.07692
; LINE_WIDTH: 1.04966
G1 F2420.689
G1 X129.033 Y125.952 E.08052
; LINE_WIDTH: 1.0766
G1 F2352.523
G1 X128.93 Y126.217 E.06196
; LINE_WIDTH: 1.06086
G1 F2391.878
G1 X128.878 Y126.292 E.01955
; LINE_WIDTH: 1.01707
G1 F2508.669
G1 X128.826 Y126.366 E.01864
; LINE_WIDTH: 0.973274
G1 F2637.45
G1 X128.774 Y126.441 E.01772
; LINE_WIDTH: 0.92948
G1 F2780.169
G1 X128.721 Y126.515 E.01682
; LINE_WIDTH: 0.885687
G1 F2939.217
G1 X128.669 Y126.59 E.01591
; LINE_WIDTH: 0.822915
G1 F3201.764
G1 X128.617 Y126.664 E.0146
G1 X128.494 Y127.244 E.09497
M204 S10000
G1 X129.239 Y129.081 F42000
; LINE_WIDTH: 0.793915
G1 F3339.579
M204 S6000
G1 X129.124 Y128.365 E.11149
G1 X129.123 Y127.675 E.10607
; LINE_WIDTH: 0.790072
G1 F3358.735
G1 X129.165 Y127.361 E.04841
; LINE_WIDTH: 0.76176
G1 F3506.948
G3 X129.209 Y127.032 I4.797 J.481 E.04862
M204 S10000
G1 X132.669 Y133.776 F42000
; LINE_WIDTH: 0.977357
G1 F2624.886
M204 S6000
G1 X132.206 Y133.366 E.12088
; LINE_WIDTH: 1.01908
G1 F2503.06
G1 X131.743 Y132.957 E.12677
; LINE_WIDTH: 1.05038
G1 F2418.835
G1 X131.73 Y132.945 E.00366
M204 S10000
G1 X112.209 Y134.521 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I6.617 J-7.364 E.44649
G1 X122.192 Y120.612 E2.65858
G2 X119.6 Y119.6 I-4.762 J8.378 E.44583
G1 X127.094 Y127.094 E1.69228
G2 X127.095 Y128.905 I6.154 J.904 E.29014
G1 X119.599 Y136.401 E1.69273
G2 X122.193 Y135.389 I-2.187 J-9.435 E.44619
G1 X110.42 Y123.616 E2.65861
G3 X112.21 Y121.48 I7.596 J4.549 E.44682
; CHANGE_LAYER
; Z_HEIGHT: 7.12
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.157 Y122.556 E-.57196
G1 X110.875 Y122.962 E-.18804
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 13/51
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z7.12 I-.631 J1.583 P1  F42000
G1 X130.209 Y130.667 Z7.12
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.403 Y130.997 E.06117
G2 X131.448 Y132.251 I5.513 J-3.532 E.26136
G1 X131.673 Y132.472 E.05032
G1 X134.781 Y135.036 E.64343
G1 X136.743 Y133.119 E.43801
G2 X141.673 Y134.875 I11.044 J-23.197 E.83711
G1 X141.625 Y135.241 E.05882
G1 X124.744 Y135.241 E2.6954
G2 X122.778 Y135.74 I.033 J4.247 E.32707
G3 X111.412 Y121.401 I-4.954 J-7.747 E4.31561
G3 X122.78 Y120.261 I6.408 J6.653 E1.96661
G2 X124.737 Y120.76 I1.998 J-3.749 E.32564
G1 X141.63 Y120.76 E2.69736
G1 X141.675 Y121.128 E.05922
G2 X136.743 Y122.876 I6.441 J26.003 E.83691
G1 X134.779 Y120.96 E.4382
G1 X131.718 Y123.49 E.63418
G2 X130.03 Y125.643 I4.924 J5.598 E.43926
G2 X129.495 Y127.49 I5.872 J2.703 E.30814
G1 X129.491 Y128.495 E.16053
G1 X129.675 Y129.446 E.15462
G2 X130.108 Y130.488 I6.241 J-1.981 E.18046
G1 X130.15 Y130.562 E.0136
M204 S10000
G1 X130.825 Y130.334 F42000
G1 F3215.099
M204 S6000
G1 X130.995 Y130.623 E.05346
G2 X131.942 Y131.756 I4.916 J-3.148 E.23642
G1 X132.142 Y131.952 E.04473
G1 X134.742 Y134.096 E.53812
G1 X136.616 Y132.264 E.41851
G2 X141.289 Y134.049 I10.389 J-20.198 E.8004
G2 X147.986 Y135.306 I11.868 J-44.745 E1.08895
G3 X147.447 Y135.761 I-2.116 J-1.959 E.113
G3 X146.777 Y135.94 I-.663 J-1.139 E.11207
G1 X124.754 Y135.94 E3.51649
G2 X123.109 Y136.357 I.022 J3.543 E.27359
G3 X117.998 Y118.114 I-5.296 J-8.354 E5.88379
G3 X123.11 Y119.644 I-.214 J10.018 E.86244
G2 X124.749 Y120.06 I1.666 J-3.127 E.2727
G1 X146.776 Y120.06 E3.51716
G3 X147.594 Y120.341 I.001 J1.33 E.14066
G1 X147.997 Y120.691 E.08517
G2 X140.61 Y122.145 I5.249 J46.172 E1.20345
G2 X136.621 Y123.735 I5.822 J20.406 E.68683
G1 X134.74 Y121.9 E.41953
G1 X132.183 Y124.013 E.5297
G2 X130.661 Y125.95 I4.415 J5.036 E.39554
G2 X130.194 Y127.558 I5.048 J2.338 E.26834
G1 X130.192 Y128.429 E.13916
G1 X130.351 Y129.253 E.13394
G2 X130.728 Y130.16 I5.56 J-1.778 E.15711
G1 X130.766 Y130.23 E.01266
; WIPE_START
G1 X130.995 Y130.623 E-.17282
G1 X131.154 Y130.859 E-.10822
M73 P52 R8
G1 X131.559 Y131.369 E-.24751
G1 X131.942 Y131.756 E-.20677
G1 X131.988 Y131.801 E-.02468
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.066 Y128.818 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X134.169 Y129.1 E.04787
G2 X134.724 Y129.956 I2.892 J-1.264 E.16365
G2 X136.188 Y131.199 I5.467 J-4.958 E.30744
G2 X139.818 Y132.87 I8.895 J-14.539 E.63968
G2 X147.569 Y134.552 I12.584 J-39.302 E1.26831
G2 X148.781 Y134.693 I4.672 J-34.939 E.19486
G3 X146.786 Y136.64 I-1.991 J-.043 E.49311
G1 X124.763 Y136.64 E3.51651
G2 X123.44 Y136.974 I.012 J2.838 E.22011
G3 X118.021 Y117.414 I-5.628 J-8.971 E6.29345
G3 X123.44 Y119.027 I-.231 J10.691 E.9137
G2 X124.761 Y119.36 I1.335 J-2.505 E.21976
G1 X146.786 Y119.36 E3.51682
G3 X148.781 Y121.31 I.004 J1.991 E.49342
G2 X140.809 Y122.815 I4.406 J45.187 E1.29712
G2 X136.833 Y124.414 I5.674 J19.854 E.6856
G2 X134.708 Y126.065 I3.503 J6.705 E.43192
G2 X133.924 Y128.183 I2.23 J2.028 E.36959
G2 X134.007 Y128.629 I3.137 J-.347 E.07252
G1 X134.03 Y128.704 E.0125
; WIPE_START
M204 S6000
G1 X134.169 Y129.1 E-.1595
G1 X134.452 Y129.604 E-.2197
G1 X134.724 Y129.956 E-.16907
G1 X135.113 Y130.355 E-.21173
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


G1 X136.901 Y134.197 F42000
G1 Z7.12
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2603
G1 F1973.476
M204 S6000
G1 X136.758 Y134.197 E.03707
G1 X136.687 Y134.321 E.03707
G1 X136.758 Y134.444 E.03707
G1 X136.901 Y134.444 E.03707
G1 X136.912 Y134.425 E.00586
M204 S10000
G1 X137.743 Y134.441 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.85901
G1 F3000
M204 S6000
G1 X138.015 Y134.494 E.04667
; LINE_WIDTH: 0.825721
G1 X138.287 Y134.546 E.04457
; LINE_WIDTH: 0.784429
G1 X138.428 Y134.571 E.02166
; LINE_WIDTH: 0.737799
G1 X138.556 Y134.593 E.0183
; LINE_WIDTH: 0.69341
G1 X138.684 Y134.615 E.01699
; LINE_WIDTH: 0.64902
G1 X138.811 Y134.637 E.01567
; LINE_WIDTH: 0.604631
G1 X138.939 Y134.66 E.01436
; LINE_WIDTH: 0.560241
G1 X139.067 Y134.682 E.01304
; LINE_WIDTH: 0.515852
G1 X139.195 Y134.704 E.01172
; LINE_WIDTH: 0.469789
G1 X139.355 Y134.729 E.01291
; LINE_WIDTH: 0.423358
G1 X139.509 Y134.753 E.01076
; LINE_WIDTH: 0.377851
G1 X139.663 Y134.777 E.00914
; LINE_WIDTH: 0.332344
G1 X139.816 Y134.801 E.00753
; LINE_WIDTH: 0.286837
G1 X139.97 Y134.825 E.00591
; LINE_WIDTH: 0.24133
G1 X140.123 Y134.849 E.0043
; WIPE_START
G1 X139.97 Y134.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.996 Y135.099 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.98509
G1 F2601.419
M204 S6000
G1 X142.543 Y135.165 E.10857
; LINE_WIDTH: 0.949295
G1 F2713.727
G1 X142.75 Y135.187 E.03952
; LINE_WIDTH: 0.905614
G1 F2864.648
G1 X142.948 Y135.208 E.03555
; LINE_WIDTH: 0.863066
G1 F3000
G1 X143.145 Y135.23 E.03362
; LINE_WIDTH: 0.820518
G1 X143.342 Y135.251 E.0317
; LINE_WIDTH: 0.777971
G1 X143.539 Y135.272 E.02977
; LINE_WIDTH: 0.731918
G1 X143.795 Y135.297 E.0359
; LINE_WIDTH: 0.683227
G1 X144.044 Y135.321 E.03212
; LINE_WIDTH: 0.635231
G1 X144.293 Y135.345 E.02938
; LINE_WIDTH: 0.587235
M73 P53 R8
G1 X144.542 Y135.369 E.02664
; LINE_WIDTH: 0.541429
G1 X144.795 Y135.391 E.02444
; LINE_WIDTH: 0.498296
G1 X145.044 Y135.412 E.02154
; LINE_WIDTH: 0.45556
G1 X145.293 Y135.434 E.0191
; LINE_WIDTH: 0.412825
G1 X145.541 Y135.455 E.01667
; LINE_WIDTH: 0.369876
G1 X145.821 Y135.476 E.01599
; LINE_WIDTH: 0.326926
G1 X146.099 Y135.498 E.01313
; LINE_WIDTH: 0.28416
G1 X146.376 Y135.519 E.01041
; LINE_WIDTH: 0.240664
G1 X146.748 Y135.545 E.01024
; WIPE_START
G1 X146.376 Y135.519 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.764 Y134.959 Z7.52 F42000
G1 X133.081 Y134.541 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X131.214 Y133.001 E.38633
G1 X130.526 Y132.314 E.15527
G1 X129.827 Y131.396 E.18431
G1 X129.321 Y130.471 E.16832
G1 X128.994 Y129.609 E.14728
G1 X128.797 Y128.588 E.16592
G1 X128.795 Y127.455 E.18103
G1 X128.962 Y126.557 E.14573
G3 X129.412 Y125.313 I11.402 J3.423 E.21138
G1 X129.914 Y124.461 E.15791
G1 X130.554 Y123.658 E.16395
G1 X131.237 Y122.981 E.15352
G3 X133.076 Y121.46 I143.574 J171.622 E.38108
G1 X130.667 Y121.46 E.38458
G1 X126.954 Y124.523 E.76856
G1 X126.947 Y131.461 E1.10789
G2 X130.664 Y134.541 I132.282 J-155.861 E.77068
G1 X132.961 Y134.541 E.36673
; WIPE_START
G1 X130.961 Y134.541 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.282 Y126.939 Z7.52 F42000
G1 X129.941 Y123.118 Z7.52
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 1.03076
G1 F2470.939
M204 S6000
G1 X130.319 Y122.776 E.10593
; LINE_WIDTH: 0.983412
G1 F2606.474
G1 X130.696 Y122.433 E.10042
; LINE_WIDTH: 0.957437
G1 F2687.337
G1 X130.851 Y122.304 E.03845
M204 S10000
G1 X127.59 Y127.212 F42000
; LINE_WIDTH: 0.694958
G1 F3914.532
M204 S6000
G2 X127.589 Y128.771 I52.206 J.808 E.2045
; LINE_WIDTH: 0.728655
G1 F3697.754
G1 X127.614 Y129.288 E.0718
; LINE_WIDTH: 0.778069
G1 F3420.012
G1 X127.639 Y129.804 E.07763
; LINE_WIDTH: 0.825911
G1 F3188.171
G1 X127.662 Y130.069 E.04284
; LINE_WIDTH: 0.872178
G1 F2992.016
G1 X127.685 Y130.334 E.04565
; LINE_WIDTH: 0.918446
G1 F2818.6
G1 X127.708 Y130.599 E.04846
; LINE_WIDTH: 0.964713
G1 F2664.184
G1 X127.731 Y130.864 E.05127
; LINE_WIDTH: 0.993122
G1 F2577.483
G1 X127.734 Y131.1 E.04688
G1 X128.953 Y132.107 E.31485
; LINE_WIDTH: 1.01484
G1 F2514.915
G1 X129.393 Y132.443 E.11301
; LINE_WIDTH: 1.04331
G1 F2437.353
G1 X129.833 Y132.778 E.1166
G1 X129.2 Y131.87 E.23321
; LINE_WIDTH: 0.993487
G1 F2576.405
G1 X128.63 Y130.845 E.23366
; LINE_WIDTH: 0.973931
G1 F2635.42
G1 X128.56 Y130.614 E.04707
; LINE_WIDTH: 0.934818
G1 F2761.952
G1 X128.489 Y130.383 E.04491
; LINE_WIDTH: 0.895706
G1 F2901.246
G1 X128.419 Y130.152 E.04276
; LINE_WIDTH: 0.856593
G1 F3055.337
G1 X128.349 Y129.92 E.0406
; LINE_WIDTH: 0.819907
G1 F3215.526
G1 X128.315 Y129.74 E.02939
; LINE_WIDTH: 0.778069
G1 F3420.012
G1 X128.241 Y129.228 E.07763
; LINE_WIDTH: 0.728655
G1 F3697.754
G1 X128.168 Y128.716 E.0718
; LINE_WIDTH: 0.693905
G1 F3921.717
G1 X128.158 Y127.452 E.16538
; LINE_WIDTH: 0.717189
G1 F3768.766
G1 X128.225 Y126.94 E.07038
; LINE_WIDTH: 0.763555
G1 F3497.169
G1 X128.291 Y126.428 E.07585
; LINE_WIDTH: 0.805617
G1 F3282.563
G1 X128.343 Y126.176 E.04013
; LINE_WIDTH: 0.843377
G1 F3111.173
G1 X128.395 Y125.925 E.04234
; LINE_WIDTH: 0.884429
G1 F2944.056
G1 X128.457 Y125.706 E.03973
; LINE_WIDTH: 0.928772
G1 F2782.604
G1 X128.518 Y125.486 E.04204
; LINE_WIDTH: 0.992339
G1 F2579.797
G3 X128.732 Y124.916 I2.16 J.486 E.12163
G1 X129.298 Y123.97 E.21938
; LINE_WIDTH: 1.00859
G1 F2532.6
G1 X129.608 Y123.56 E.1041
; LINE_WIDTH: 1.03739
G1 F2453.074
G2 X129.941 Y123.118 I-6.892 J-5.531 E.11585
G1 X129.908 Y123.141 E.00838
; LINE_WIDTH: 1.0352
G1 F2458.949
G1 X129.504 Y123.458 E.10722
; LINE_WIDTH: 0.998281
G1 F2562.339
G2 X127.735 Y124.9 I26.91 J34.812 E.45729
; LINE_WIDTH: 0.97673
G1 F2626.807
G1 X127.716 Y125.163 E.05165
; LINE_WIDTH: 0.939617
G1 F2745.778
G1 X127.698 Y125.427 E.04941
; LINE_WIDTH: 0.902504
G1 F2876.036
G1 X127.679 Y125.691 E.04717
; LINE_WIDTH: 0.863632
G1 F3026.41
G1 X127.659 Y125.961 E.04603
; LINE_WIDTH: 0.823002
G1 F3201.366
G1 X127.639 Y126.232 E.04351
; LINE_WIDTH: 0.778427
G1 F3418.154
G1 X127.617 Y126.662 E.06468
; LINE_WIDTH: 0.729907
G1 F3690.158
G1 X127.596 Y127.092 E.05991
M204 S10000
G1 X130.94 Y133.772 F42000
; LINE_WIDTH: 0.981437
G1 F2612.452
M204 S6000
G1 X130.444 Y133.332 E.13036
; LINE_WIDTH: 1.02876
G1 F2476.392
G1 X129.948 Y132.891 E.13752
; LINE_WIDTH: 1.06566
G1 F2379.744
G1 X129.919 Y132.862 E.00892
; WIPE_START
G1 X129.948 Y132.891 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.393 Y126.686 Z7.52 F42000
G1 X135.786 Y124.741 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828097
G1 F3178.325
M204 S2000
G1 X134.18 Y123.135 E.36702
G1 X133.632 Y123.588 E.11486
G1 X134.994 Y124.95 E.31113
G2 X134.477 Y125.435 I4.681 J5.501 E.11445
G1 X133.084 Y124.041 E.3184
G2 X132.538 Y124.497 I2.835 J3.943 E.1149
G1 X134.02 Y125.979 E.33852
G2 X133.648 Y126.608 I4.742 J3.231 E.11812
G1 X132.036 Y124.995 E.36833
G2 X131.592 Y125.553 I5.731 J5.016 E.11512
G1 X133.396 Y127.357 E.4121
G2 X133.339 Y128.301 I2.655 J.633 E.1536
G1 X131.217 Y126.178 E.48491
G1 X131.198 Y126.211 E.00603
G2 X130.938 Y126.901 I3.73 J1.795 E.11932
G1 X136.036 Y131.999 E1.16449
G1 X135.53 Y132.494 E.11435
G1 X130.789 Y127.753 E1.08307
G1 X130.787 Y128.373 E.10023
G1 X130.877 Y128.842 E.0772
G1 X135.024 Y132.989 E.94717
G1 X134.708 Y133.298 E.07132
G1 X132.558 Y131.525 E.45005
G1 X130.887 Y129.854 E.38172
; WIPE_START
M204 S6000
G1 X132.301 Y131.268 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.722 Y124.445 Z7.52 F42000
G1 X136.866 Y122.162 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819367
G1 F3218.01
M204 S6000
G1 X136.762 Y121.969 E.03496
; LINE_WIDTH: 0.857747
G1 F3050.558
G1 X136.658 Y121.776 E.03688
; LINE_WIDTH: 0.898587
G1 F2890.508
G1 X136.656 Y121.764 E.0022
; LINE_WIDTH: 0.941887
G1 F2738.192
G1 X136.654 Y121.751 E.00232
; LINE_WIDTH: 0.985187
G1 F2601.126
G1 X136.652 Y121.739 E.00244
; LINE_WIDTH: 1.02849
G1 F2477.128
G1 X136.65 Y121.727 E.00256
; LINE_WIDTH: 1.07179
G1 F2364.414
G1 X136.648 Y121.715 E.00269
M204 S10000
G1 X137.834 Y122.002 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.830179
G1 F3000
M204 S6000
G1 X138.094 Y121.516 E.08925
; LINE_WIDTH: 0.854947
G1 X138.109 Y121.488 E.00529
G1 X138.227 Y121.466 E.02022
; LINE_WIDTH: 0.810935
G1 X138.346 Y121.444 E.019
; LINE_WIDTH: 0.767186
G1 X138.464 Y121.422 E.0178
; LINE_WIDTH: 0.721906
G1 X138.601 Y121.399 E.01904
; LINE_WIDTH: 0.676761
G1 X138.729 Y121.377 E.01652
; LINE_WIDTH: 0.633071
G1 X138.857 Y121.355 E.01522
; LINE_WIDTH: 0.58938
G1 X138.986 Y121.333 E.01392
; LINE_WIDTH: 0.54569
G1 X139.114 Y121.312 E.01263
; LINE_WIDTH: 0.501999
G1 X139.242 Y121.29 E.01133
; LINE_WIDTH: 0.458308
G1 X139.37 Y121.268 E.01003
; LINE_WIDTH: 0.413893
G1 X139.526 Y121.244 E.01057
; LINE_WIDTH: 0.369901
G1 X139.677 Y121.221 E.00869
; LINE_WIDTH: 0.326663
G1 X139.828 Y121.198 E.00718
; LINE_WIDTH: 0.283426
G1 X139.978 Y121.175 E.00568
; LINE_WIDTH: 0.240188
G1 X140.129 Y121.152 E.00417
; WIPE_START
G1 X139.978 Y121.175 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142 Y120.898 Z7.52 F42000
G1 Z7.12
G1 E.8 F1800
; LINE_WIDTH: 0.976457
G1 F2627.646
M204 S6000
G1 X142.31 Y120.863 E.061
; LINE_WIDTH: 0.931537
G1 F2773.123
G1 X142.62 Y120.829 E.0578
; LINE_WIDTH: 0.886616
G1 F2935.653
G1 X142.931 Y120.794 E.0546
; LINE_WIDTH: 0.841696
G1 F3000
G1 X143.241 Y120.759 E.0514
; LINE_WIDTH: 0.795975
G1 X143.474 Y120.736 E.03618
; LINE_WIDTH: 0.750516
G1 X143.699 Y120.714 E.0325
; LINE_WIDTH: 0.705915
G1 X143.924 Y120.692 E.0302
; LINE_WIDTH: 0.661314
G1 X144.149 Y120.669 E.0279
; LINE_WIDTH: 0.616714
G1 X144.374 Y120.647 E.0256
; LINE_WIDTH: 0.573597
G1 X144.613 Y120.626 E.02479
; LINE_WIDTH: 0.53261
G1 X144.845 Y120.606 E.022
; LINE_WIDTH: 0.492126
G1 X145.078 Y120.586 E.01984
; LINE_WIDTH: 0.451642
G1 X145.311 Y120.566 E.01768
; LINE_WIDTH: 0.411157
G1 X145.544 Y120.545 E.01552
; LINE_WIDTH: 0.36916
G1 X145.845 Y120.523 E.01711
; LINE_WIDTH: 0.325974
G1 X146.142 Y120.5 E.014
; LINE_WIDTH: 0.283011
G1 X146.439 Y120.478 E.01108
; LINE_WIDTH: 0.240049
G1 X146.736 Y120.455 E.00815
; WIPE_START
G1 X146.439 Y120.478 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.378 Y123.375 Z7.52 F42000
G1 X112.209 Y134.521 Z7.52
G1 Z7.12
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X112.208 Y134.52 E.00029
G3 X110.419 Y132.385 I6.427 J-7.199 E.44626
G1 X122.192 Y120.612 E2.65852
G2 X119.601 Y119.601 I-4.763 J8.383 E.44578
G1 X126.248 Y126.248 E1.50103
G1 X126.248 Y129.752 E.55958
G1 X119.599 Y136.401 E1.50136
G2 X122.193 Y135.389 I-2.189 J-9.443 E.44612
G1 X110.421 Y123.617 E2.65837
G3 X112.21 Y121.48 I7.563 J4.516 E.44679
; CHANGE_LAYER
; Z_HEIGHT: 7.68
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.5724
G1 X110.875 Y122.963 E-.1876
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
G3 Z7.68 I-.728 J1.54 P1  F42000
G1 X129.11 Y131.58 Z7.68
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.305 Y131.83 E.05057
G1 X129.933 Y132.459 E.14185
G1 X133.067 Y135.046 E.64896
G1 X135.027 Y133.123 E.43842
G2 X139.948 Y134.875 I11.19 J-23.638 E.83556
G1 X139.901 Y135.241 E.05882
G1 X124.744 Y135.241 E2.42007
G2 X122.778 Y135.74 I.033 J4.247 E.32717
G3 X112.723 Y120.345 I-4.955 J-7.745 E4.58458
G3 X122.779 Y120.261 I5.093 J7.717 E1.69782
G2 X124.736 Y120.76 I1.998 J-3.748 E.32555
G1 X139.906 Y120.76 E2.42222
G1 X139.951 Y121.128 E.05924
G2 X135.024 Y122.875 I5.759 J24.061 E.83636
G1 X133.067 Y120.97 E.43613
G1 X129.955 Y123.523 E.64272
G1 X129.308 Y124.167 E.14584
G1 X128.759 Y124.869 E.14218
G1 X128.298 Y125.657 E.14584
G1 X127.951 Y126.563 E.15494
G1 X127.771 Y127.508 E.15363
G1 X127.77 Y128.485 E.15601
G1 X127.957 Y129.46 E.15857
G1 X128.3 Y130.349 E.15211
G1 X128.762 Y131.136 E.14572
G1 X129.036 Y131.486 E.07092
M204 S10000
G1 X129.672 Y131.163 F42000
G1 F3215.099
M204 S6000
G1 X129.83 Y131.365 E.04095
G1 X130.404 Y131.94 E.12973
G1 X133.027 Y134.105 E.54298
G1 X134.9 Y132.268 E.41895
G2 X139.614 Y134.062 I10.177 J-19.649 E.80719
G2 X147.433 Y135.434 I12.141 J-46.216 E1.26903
G1 X147.486 Y135.749 E.05107
G3 X146.777 Y135.94 I-.729 J-1.291 E.11853
G1 X124.754 Y135.94 E3.51656
G2 X123.109 Y136.357 I.022 J3.542 E.27366
G3 X118.009 Y118.114 I-5.295 J-8.354 E5.88507
G3 X123.11 Y119.644 I-.225 J10.017 E.86061
G2 X124.749 Y120.06 I1.667 J-3.126 E.27267
G1 X146.776 Y120.06 E3.51728
G3 X147.485 Y120.25 I-.019 J1.489 E.11842
G1 X147.434 Y120.566 E.05105
G2 X138.888 Y122.144 I4.152 J46.401 E1.38971
G2 X134.902 Y123.733 I5.89 J20.567 E.68632
G1 X133.027 Y121.908 E.41782
G1 X130.425 Y124.042 E.5374
G1 X129.833 Y124.633 E.13355
G1 X129.34 Y125.263 E.12774
G1 X128.931 Y125.961 E.12916
G1 X128.627 Y126.755 E.13586
G1 X128.471 Y127.575 E.13316
G1 X128.47 Y128.419 E.13486
G1 X128.632 Y129.267 E.13785
G1 X128.932 Y130.044 E.13298
G1 X129.342 Y130.741 E.12918
G1 X129.598 Y131.069 E.06638
; WIPE_START
G1 X129.83 Y131.365 E-.14305
G1 X130.404 Y131.94 E-.30873
G1 X131.03 Y132.457 E-.30822
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.637 Y129.448 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.693 Y129.549 E.01843
G2 X134.474 Y131.205 I5.011 J-3.603 E.39077
G2 X138.429 Y132.98 I9.174 J-15.15 E.69398
G2 X145.812 Y134.547 I12.198 J-39.274 E1.20688
G2 X148.77 Y134.851 I8.282 J-66.077 E.47482
G3 X146.786 Y136.64 I-1.987 J-.209 E.46717
G1 X124.763 Y136.64 E3.51654
G2 X123.44 Y136.974 I.012 J2.838 E.22015
G3 X118.031 Y117.414 I-5.627 J-8.972 E6.29453
G3 X123.44 Y119.026 I-.242 J10.691 E.91196
G2 X124.761 Y119.36 I1.336 J-2.505 E.21977
G1 X146.786 Y119.36 E3.51685
G3 X148.771 Y121.149 I-.007 J2.004 E.46702
G2 X139.966 Y122.568 I3.56 J50.123 E1.426
G2 X135.75 Y124.081 I5.833 J22.887 E.71633
G2 X133.363 Y125.666 I3.926 J8.5 E.45942
G2 X132.318 Y127.227 I2.616 J2.883 E.30282
G2 X132.438 Y129.1 I2.568 J.776 E.30626
G1 X132.578 Y129.344 E.04489
; WIPE_START
M204 S6000
G1 X132.693 Y129.549 E-.08947
G1 X133.065 Y130.033 E-.2319
M73 P54 R8
G1 X133.489 Y130.458 E-.22814
G1 X133.916 Y130.811 E-.21049
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


G1 X134.064 Y131.26 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.828137
G1 F3178.146
M204 S2000
G1 X132.459 Y132.865 E.36668
G1 X131.911 Y132.412 E.11488
G1 X133.272 Y131.051 E.31108
G3 X132.756 Y130.566 I3.193 J-3.924 E.11451
G1 X131.362 Y131.96 E.31832
G1 X130.814 Y131.507 E.11488
G1 X132.294 Y130.019 E.33904
G3 X131.925 Y129.394 I4.826 J-3.269 E.11735
G1 X130.313 Y131.006 E.36836
G1 X129.869 Y130.449 E.11509
G1 X131.674 Y128.644 E.41239
G3 X131.614 Y127.703 I2.665 J-.643 E.15305
G1 X129.493 Y129.824 E.48446
G1 X129.208 Y129.107 E.12455
G1 X134.319 Y123.996 E1.16755
G1 X133.812 Y123.502 E.11437
G1 X129.065 Y128.25 E1.08448
G1 X129.065 Y127.631 E.09996
G1 X129.156 Y127.158 E.0778
G1 X133.305 Y123.008 E.94787
G1 X132.993 Y122.705 E.07028
G1 X130.845 Y124.467 E.44874
G1 X129.156 Y126.156 E.38584
; WIPE_START
M204 S6000
G1 X130.571 Y124.742 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.259 Y122.912 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 1.26089
G1 F1972.444
M204 S6000
G1 X130.654 Y121.758 E.47124
M204 S10000
G1 X129.259 Y122.912 F42000
; LINE_WIDTH: 1.24492
G1 F2000.45
M204 S6000
G1 X129.219 Y122.915 E.01041
; LINE_WIDTH: 1.19866
G1 F2086.267
G1 X129.178 Y122.919 E.00998
; LINE_WIDTH: 1.15239
G1 F2179.778
G1 X129.138 Y122.922 E.00955
; LINE_WIDTH: 1.10613
G1 F2282.064
G1 X129.097 Y122.925 E.00912
; LINE_WIDTH: 1.05986
G1 F2394.423
G1 X129.057 Y122.929 E.00869
; LINE_WIDTH: 1.01359
G1 F2518.418
G1 X129.017 Y122.932 E.00826
; LINE_WIDTH: 0.967329
G1 F2655.957
G1 X128.976 Y122.935 E.00784
; LINE_WIDTH: 0.921063
G1 F2809.388
G1 X128.936 Y122.939 E.00741
; LINE_WIDTH: 0.874797
G1 F2981.632
G1 X128.895 Y122.942 E.00698
; LINE_WIDTH: 0.828532
G1 F3176.375
G1 X128.855 Y122.945 E.00655
; LINE_WIDTH: 0.782266
G1 F3398.336
G1 X128.815 Y122.949 E.00613
; LINE_WIDTH: 0.726378
G1 F3711.641
G1 X128.774 Y122.952 E.00561
G1 X128.379 Y123.294 E.07232
; LINE_WIDTH: 0.755819
G1 F3539.73
G1 X128.143 Y123.512 E.0466
; LINE_WIDTH: 0.790662
G1 F3355.78
G1 X127.906 Y123.73 E.04915
; LINE_WIDTH: 0.825505
G1 F3190.004
G1 X127.67 Y123.947 E.05171
; LINE_WIDTH: 0.862952
G1 F3029.181
G1 X127.504 Y124.11 E.0394
; LINE_WIDTH: 0.903002
G1 F2874.206
G1 X127.338 Y124.273 E.04153
; LINE_WIDTH: 0.960147
G1 F2678.666
G3 X127.019 Y124.562 I-1.834 J-1.703 E.08266
G3 X127.013 Y127.397 I-240.046 J.904 E.54331
G1 X127.22 Y126.316 E.21097
G1 X127.588 Y125.354 E.1974
G1 X127.804 Y124.974 E.08386
; LINE_WIDTH: 0.945404
G1 F2726.524
G1 X127.92 Y124.811 E.03759
; LINE_WIDTH: 0.910057
G1 F2848.534
G1 X128.036 Y124.648 E.03598
; LINE_WIDTH: 0.87471
G1 F2981.976
G1 X128.151 Y124.485 E.03437
; LINE_WIDTH: 0.8377
G1 F3135.787
G1 X128.368 Y124.238 E.05384
; LINE_WIDTH: 0.799027
G1 F3314.429
G1 X128.585 Y123.991 E.05094
; LINE_WIDTH: 0.760354
G1 F3514.655
G1 X128.801 Y123.743 E.04804
; LINE_WIDTH: 0.726942
G1 F3708.19
G1 X129.172 Y123.39 E.07085
; LINE_WIDTH: 0.736
G1 F3653.648
G1 X129.177 Y123.36 E.00429
; LINE_WIDTH: 0.782266
G1 F3398.336
G1 X129.183 Y123.33 E.00461
; LINE_WIDTH: 0.828532
G1 F3176.375
G1 X129.188 Y123.3 E.00494
; LINE_WIDTH: 0.874797
G1 F2981.632
G1 X129.194 Y123.27 E.00526
; LINE_WIDTH: 0.921063
G1 F2809.388
G1 X129.199 Y123.24 E.00558
; LINE_WIDTH: 0.967329
G1 F2655.957
G1 X129.205 Y123.21 E.0059
; LINE_WIDTH: 1.01359
G1 F2518.418
G1 X129.21 Y123.18 E.00623
; LINE_WIDTH: 1.05986
G1 F2394.423
G1 X129.216 Y123.15 E.00655
; LINE_WIDTH: 1.10613
G1 F2282.064
G1 X129.221 Y123.12 E.00687
; LINE_WIDTH: 1.15239
G1 F2179.778
G1 X129.227 Y123.09 E.00719
; LINE_WIDTH: 1.19866
G1 F2086.267
G1 X129.232 Y123.06 E.00752
; LINE_WIDTH: 1.24492
G1 F2000.45
G1 X129.238 Y123.03 E.00784
M204 S10000
G1 X127.012 Y128.59 F42000
; LINE_WIDTH: 0.94325
G1 F2733.657
M204 S6000
G3 X127.009 Y127.517 I12.271 J-.566 E.20152
M204 S10000
G1 X127.012 Y128.59 F42000
; LINE_WIDTH: 0.959876
G1 F2679.531
M204 S6000
G1 X127.012 Y128.596 E.00126
G3 X127.019 Y131.437 I-241.374 J1.95 E.54418
; LINE_WIDTH: 0.944622
G1 F2729.109
G1 X127.214 Y131.621 E.05047
; LINE_WIDTH: 0.909072
G1 F2852.091
G1 X127.409 Y131.805 E.0483
; LINE_WIDTH: 0.873522
G1 F2986.68
G1 X127.604 Y131.989 E.04612
; LINE_WIDTH: 0.836719
G1 F3140.083
G1 X127.855 Y132.221 E.0558
; LINE_WIDTH: 0.798662
G1 F3316.212
G1 X128.105 Y132.453 E.05283
; LINE_WIDTH: 0.760605
G1 F3513.274
G1 X128.356 Y132.685 E.04987
; LINE_WIDTH: 0.727367
G1 F3705.595
G1 X128.767 Y133.043 E.07551
; LINE_WIDTH: 0.736265
G1 F3652.079
G1 X128.807 Y133.046 E.0057
; LINE_WIDTH: 0.78248
G1 F3397.239
G1 X128.847 Y133.049 E.00612
; LINE_WIDTH: 0.828695
G1 F3175.645
G1 X128.888 Y133.053 E.00655
; LINE_WIDTH: 0.87491
G1 F2981.189
G1 X128.928 Y133.056 E.00698
; LINE_WIDTH: 0.921125
G1 F2809.173
G1 X128.969 Y133.06 E.00741
; LINE_WIDTH: 0.96734
G1 F2655.925
G1 X129.009 Y133.063 E.00783
; LINE_WIDTH: 1.01355
G1 F2518.532
G1 X129.049 Y133.066 E.00826
; LINE_WIDTH: 1.05977
G1 F2394.655
G1 X129.09 Y133.07 E.00869
; LINE_WIDTH: 1.10598
G1 F2282.393
G1 X129.13 Y133.073 E.00911
; LINE_WIDTH: 1.1522
G1 F2180.185
G1 X129.17 Y133.076 E.00954
; LINE_WIDTH: 1.19841
G1 F2086.739
G1 X129.211 Y133.08 E.00997
; LINE_WIDTH: 1.24463
G1 F2000.974
G1 X129.251 Y133.083 E.0104
G1 X129.244 Y133.043 E.0104
; LINE_WIDTH: 1.19841
G1 F2086.739
G1 X129.237 Y133.003 E.00997
; LINE_WIDTH: 1.1522
G1 F2180.185
G1 X129.23 Y132.964 E.00954
; LINE_WIDTH: 1.10598
G1 F2282.393
G1 X129.223 Y132.924 E.00912
; LINE_WIDTH: 1.05977
G1 F2394.655
G1 X129.215 Y132.884 E.00869
; LINE_WIDTH: 1.01355
G1 F2518.532
G1 X129.208 Y132.844 E.00826
; LINE_WIDTH: 0.96734
G1 F2655.925
G1 X129.201 Y132.804 E.00783
; LINE_WIDTH: 0.921125
G1 F2809.173
G1 X129.194 Y132.764 E.00741
; LINE_WIDTH: 0.87491
G1 F2981.189
G1 X129.187 Y132.724 E.00698
; LINE_WIDTH: 0.828695
G1 F3175.645
G1 X129.18 Y132.684 E.00655
; LINE_WIDTH: 0.78248
G1 F3397.239
G1 X129.173 Y132.644 E.00612
; LINE_WIDTH: 0.728024
G1 F3701.587
G1 X129.165 Y132.605 E.00562
G1 X128.798 Y132.254 E.07045
; LINE_WIDTH: 0.758305
G1 F3525.937
G1 X128.595 Y132.021 E.04498
; LINE_WIDTH: 0.791762
G1 F3350.283
G1 X128.392 Y131.788 E.04734
; LINE_WIDTH: 0.825219
G1 F3191.301
G1 X128.188 Y131.556 E.0497
; LINE_WIDTH: 0.862022
G1 F3032.979
G1 X128.06 Y131.379 E.037
; LINE_WIDTH: 0.902172
G1 F2877.256
G1 X127.931 Y131.202 E.039
; LINE_WIDTH: 0.958396
G1 F2684.262
G3 X127.591 Y130.654 I2.315 J-1.816 E.12369
G1 X127.226 Y129.709 E.19366
G1 X127.033 Y128.708 E.19497
M204 S10000
G1 X130.743 Y134.321 F42000
; LINE_WIDTH: 1.26015
G1 F1973.736
M204 S6000
G1 X129.341 Y133.163 E.47292
; WIPE_START
G1 X130.743 Y134.321 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.18 Y134.202 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.25166
G1 F1988.546
M204 S6000
G1 X135.039 Y134.202 E.03651
G1 X134.968 Y134.325 E.03651
G1 X135.039 Y134.447 E.03651
G1 X135.18 Y134.447 E.03651
G1 X135.191 Y134.429 E.00553
M204 S10000
G1 X136.019 Y134.441 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.858554
G1 F3000
M204 S6000
G1 X136.294 Y134.494 E.04718
; LINE_WIDTH: 0.824049
G1 X136.569 Y134.547 E.04498
; LINE_WIDTH: 0.782072
G1 X136.711 Y134.572 E.02168
; LINE_WIDTH: 0.735318
G1 X136.839 Y134.594 E.01829
; LINE_WIDTH: 0.690831
G1 X136.968 Y134.617 E.01697
; LINE_WIDTH: 0.646343
G1 X137.096 Y134.639 E.01564
; LINE_WIDTH: 0.601856
G1 X137.224 Y134.661 E.01432
; LINE_WIDTH: 0.557368
G1 X137.353 Y134.683 E.013
; LINE_WIDTH: 0.512881
G1 X137.481 Y134.705 E.01168
; LINE_WIDTH: 0.467033
G1 X137.64 Y134.73 E.01269
; LINE_WIDTH: 0.421142
G1 X137.792 Y134.754 E.01058
; LINE_WIDTH: 0.376172
G1 X137.944 Y134.778 E.009
; LINE_WIDTH: 0.331202
G1 X138.096 Y134.802 E.00742
; LINE_WIDTH: 0.286232
G1 X138.249 Y134.825 E.00584
; LINE_WIDTH: 0.241262
G1 X138.401 Y134.849 E.00426
; WIPE_START
G1 X138.249 Y134.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.272 Y135.099 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.986649
G1 F2596.736
M204 S6000
G1 X140.806 Y135.163 E.10629
; LINE_WIDTH: 0.951894
G1 F2705.246
G1 X141.017 Y135.186 E.04036
; LINE_WIDTH: 0.907403
G1 F2858.138
G1 X141.218 Y135.208 E.03627
; LINE_WIDTH: 0.86407
G1 F3000
G1 X141.419 Y135.229 E.03427
; LINE_WIDTH: 0.820737
G1 X141.62 Y135.251 E.03228
; LINE_WIDTH: 0.777404
G1 X141.82 Y135.273 E.03028
; LINE_WIDTH: 0.755004
G1 X141.828 Y135.273 E.00106
; LINE_WIDTH: 0.729855
G1 X142.081 Y135.298 E.0354
; LINE_WIDTH: 0.681067
G1 X142.334 Y135.322 E.03257
; LINE_WIDTH: 0.632279
G1 X142.588 Y135.347 E.02974
; LINE_WIDTH: 0.583491
G1 X142.841 Y135.371 E.0269
; LINE_WIDTH: 0.536927
G1 X143.1 Y135.393 E.02467
; LINE_WIDTH: 0.493095
G1 X143.353 Y135.415 E.02168
; LINE_WIDTH: 0.449664
G1 X143.607 Y135.437 E.01915
; LINE_WIDTH: 0.406233
G1 X143.861 Y135.458 E.01663
; LINE_WIDTH: 0.36367
G1 X144.152 Y135.48 E.0162
; LINE_WIDTH: 0.322264
G1 X144.44 Y135.502 E.01332
; LINE_WIDTH: 0.281061
G1 X144.728 Y135.523 E.0106
; LINE_WIDTH: 0.239858
G1 X145.016 Y135.545 E.00789
; WIPE_START
G1 X144.728 Y135.523 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.874 Y127.892 Z8.08 F42000
G1 X145.016 Y120.455 Z8.08
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.239221
G1 F3000
M204 S6000
G1 X144.729 Y120.477 E.00784
; LINE_WIDTH: 0.280523
G1 X144.441 Y120.499 E.01055
; LINE_WIDTH: 0.321824
G1 X144.153 Y120.52 E.01327
; LINE_WIDTH: 0.363343
G1 X143.863 Y120.542 E.01617
; LINE_WIDTH: 0.40429
G1 X143.631 Y120.562 E.01507
; LINE_WIDTH: 0.444354
G1 X143.399 Y120.582 E.0172
; LINE_WIDTH: 0.484418
G1 X143.168 Y120.602 E.01932
; LINE_WIDTH: 0.524481
G1 X142.936 Y120.622 E.02145
; LINE_WIDTH: 0.5649
G1 X142.7 Y120.643 E.02401
; LINE_WIDTH: 0.604901
G1 X142.495 Y120.662 E.02281
; LINE_WIDTH: 0.644322
G1 X142.287 Y120.682 E.025
; LINE_WIDTH: 0.688338
G1 X142.047 Y120.706 E.03131
; LINE_WIDTH: 0.736625
G1 X141.806 Y120.73 E.03397
; LINE_WIDTH: 0.78545
G1 X141.561 Y120.755 E.03747
; LINE_WIDTH: 0.834926
G1 X141.332 Y120.78 E.03749
; LINE_WIDTH: 0.884427
G1 F2944.065
G1 X141.103 Y120.804 E.04009
; LINE_WIDTH: 0.909634
G1 F2850.06
G1 X141.099 Y120.805 E.00073
; LINE_WIDTH: 0.932065
G1 F2771.319
G1 X140.688 Y120.852 E.0768
; LINE_WIDTH: 0.976046
G1 F2628.906
G1 X140.276 Y120.898 E.08096
; WIPE_START
G1 X140.688 Y120.852 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.406 Y121.152 Z8.08 F42000
G1 Z7.68
G1 E.8 F1800
; LINE_WIDTH: 0.240607
G1 F3000
M204 S6000
G1 X138.252 Y121.175 E.00426
; LINE_WIDTH: 0.284676
G1 X138.099 Y121.199 E.00582
; LINE_WIDTH: 0.328745
G1 X137.946 Y121.222 E.00738
; LINE_WIDTH: 0.372814
G1 X137.792 Y121.246 E.00894
; LINE_WIDTH: 0.417663
G1 X137.634 Y121.27 E.0109
; LINE_WIDTH: 0.462914
G1 X137.504 Y121.292 E.01033
; LINE_WIDTH: 0.507407
G1 X137.373 Y121.315 E.01167
; LINE_WIDTH: 0.551899
G1 X137.243 Y121.337 E.01302
; LINE_WIDTH: 0.596392
G1 X137.113 Y121.359 E.01436
; LINE_WIDTH: 0.640885
G1 X136.983 Y121.381 E.0157
; LINE_WIDTH: 0.685378
G1 X136.852 Y121.403 E.01704
; LINE_WIDTH: 0.731304
G1 X136.714 Y121.427 E.01961
; LINE_WIDTH: 0.77434
G1 X136.609 Y121.446 E.01585
; LINE_WIDTH: 0.812851
G1 X136.505 Y121.466 E.01678
; LINE_WIDTH: 0.869629
G1 X136.015 Y121.559 E.08534
M204 S10000
G1 X135.175 Y121.553 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2518
G1 F1988.3
M204 S6000
G1 X135.034 Y121.553 E.03652
G1 X134.963 Y121.676 E.03652
G1 X135.034 Y121.798 E.03652
G1 X135.175 Y121.798 E.03652
G1 X135.186 Y121.78 E.00554
; WIPE_START
G1 X135.175 Y121.798 E-.02775
G1 X135.034 Y121.798 E-.18307
G1 X134.963 Y121.676 E-.18306
G1 X135.034 Y121.553 E-.18307
G1 X135.175 Y121.553 E-.18305
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.543 Y121.529 Z8.08 F42000
G1 X112.21 Y121.481 Z8.08
G1 Z7.68
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.421 Y123.617 I5.774 J6.653 E.44678
G1 X122.193 Y135.389 E2.65835
G3 X119.599 Y136.401 I-4.786 J-8.44 E.44605
G1 X126.248 Y129.752 E1.50128
G1 X126.248 Y126.248 E.55958
G1 X119.601 Y119.601 E1.50096
G3 X122.192 Y120.612 I-2.173 J9.399 E.44571
G1 X110.419 Y132.385 E2.65859
G2 X112.209 Y134.521 I7.519 J-4.484 E.44691
; CHANGE_LAYER
; Z_HEIGHT: 8.24
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.177 Y133.469 E-.55989
G1 X110.876 Y133.038 E-.20011
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 15/51
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z8.24 I.042 J1.703 P1  F42000
G1 X128.39 Y132.607 Z8.24
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.337 Y135.042 E.61043
G1 X133.306 Y133.125 E.4389
G2 X137.752 Y134.749 I10.832 J-22.745 E.75684
G1 X138.224 Y134.875 E.07808
G1 X138.176 Y135.241 E.05882
G1 X124.744 Y135.241 E2.14471
G2 X122.777 Y135.741 I.032 J4.247 E.32723
G3 X114.202 Y119.548 I-4.956 J-7.743 E4.85301
G3 X122.779 Y120.261 I3.61 J8.515 E1.42947
G2 X124.736 Y120.76 I1.998 J-3.748 E.32557
G1 X138.179 Y120.76 E2.14652
G1 X138.225 Y121.127 E.05913
G2 X133.302 Y122.872 I6.287 J25.552 E.83543
G1 X131.339 Y120.96 E.43758
G1 X126.99 Y124.548 E.90036
G1 X126.99 Y131.45 E1.10207
G1 X128.298 Y132.531 E.27089
M204 S10000
G1 X128.854 Y132.083 F42000
G1 F3215.099
M204 S6000
G1 X131.299 Y134.103 E.50634
G1 X133.183 Y132.268 E.41989
G2 X137.346 Y133.909 I9.902 J-19.023 E.71582
G2 X145.047 Y135.367 I12.475 J-44.832 E1.25299
G2 X146.866 Y135.538 I5.917 J-53.026 E.29181
G1 X146.849 Y135.94 E.06429
G1 X124.754 Y135.94 E3.52811
G2 X123.108 Y136.357 I.022 J3.542 E.27372
G3 X118.018 Y118.114 I-5.293 J-8.355 E5.88542
G3 X123.109 Y119.644 I-.234 J10.017 E.85907
G2 X124.749 Y120.06 I1.667 J-3.126 E.27268
G1 X146.858 Y120.06 E3.53031
G1 X146.875 Y120.462 E.06421
G2 X138.078 Y121.887 I3.583 J49.971 E1.42498
G2 X133.732 Y123.445 I6.515 J25.014 E.73811
G1 X133.181 Y123.732 E.09915
G1 X131.3 Y121.899 E.4193
G1 X127.689 Y124.878 E.74745
G1 X127.69 Y131.121 E.99677
G1 X128.762 Y132.007 E.22208
; WIPE_START
G1 X130.304 Y133.281 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.445 Y130.138 Z8.64 F42000
M73 P55 R8
G1 Z8.24
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.762 Y130.448 E.07072
G2 X132.294 Y130.887 I4.1 J-4.44 E.11013
G2 X135.595 Y132.593 I8.116 J-11.654 E.59512
G2 X142.369 Y134.298 I12.258 J-34.384 E1.11701
G2 X148.757 Y134.963 I9.517 J-60.46 E1.02597
G3 X146.787 Y136.64 I-1.967 J-.314 E.44975
G1 X124.763 Y136.64 E3.51655
G2 X123.439 Y136.974 I.012 J2.838 E.22021
G3 X118.041 Y117.415 I-5.624 J-8.973 E6.29472
G3 X123.44 Y119.026 I-.251 J10.691 E.91041
G2 X124.761 Y119.36 I1.336 J-2.504 E.21981
G1 X146.786 Y119.36 E3.51686
G3 X148.757 Y121.038 I0 J1.996 E.44962
G2 X138.617 Y122.472 I2.348 J53.179 E1.63776
G2 X134.039 Y124.074 I5.874 J24.119 E.77566
G2 X131.775 Y125.534 I4.182 J8.971 E.43158
G2 X130.749 Y126.834 I3.261 J3.629 E.26559
G2 X130.48 Y128.229 I2.636 J1.233 E.22928
G2 X131.007 Y129.608 I3.059 J-.38 E.23803
G2 X131.36 Y130.041 I4.854 J-3.599 E.08916
G1 X131.367 Y130.048 E.0016
; WIPE_START
M204 S6000
G1 X131.762 Y130.448 E-.21379
G1 X132.294 Y130.887 E-.26196
G1 X132.76 Y131.211 E-.21589
G1 X132.914 Y131.304 E-.06836
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


G1 X133.456 Y134.203 F42000
G1 Z8.24
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2513
G1 F1989.179
M204 S6000
G1 X133.315 Y134.203 E.03649
G1 X133.244 Y134.325 E.03649
G1 X133.315 Y134.448 E.03649
G1 X133.456 Y134.448 E.03649
G1 X133.467 Y134.429 E.00552
M204 S10000
G1 X134.296 Y134.441 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.858433
G1 F3000
M204 S6000
G1 X134.572 Y134.495 E.04739
; LINE_WIDTH: 0.823449
G1 X134.848 Y134.548 E.04514
; LINE_WIDTH: 0.803542
G1 X134.861 Y134.55 E.00209
; LINE_WIDTH: 0.778343
G1 X134.993 Y134.573 E.02007
; LINE_WIDTH: 0.732776
G1 X135.125 Y134.596 E.01868
; LINE_WIDTH: 0.687209
G1 X135.256 Y134.619 E.01729
; LINE_WIDTH: 0.641642
G1 X135.388 Y134.641 E.0159
; LINE_WIDTH: 0.596075
G1 X135.52 Y134.664 E.01451
; LINE_WIDTH: 0.550508
G1 X135.651 Y134.687 E.01312
; LINE_WIDTH: 0.504941
G1 X135.783 Y134.71 E.01173
; LINE_WIDTH: 0.459252
G1 X135.938 Y134.734 E.0121
; LINE_WIDTH: 0.414744
G1 X136.086 Y134.757 E.01009
; LINE_WIDTH: 0.371152
G1 X136.234 Y134.78 E.0086
; LINE_WIDTH: 0.327559
G1 X136.383 Y134.803 E.0071
; LINE_WIDTH: 0.283966
G1 X136.531 Y134.826 E.00561
; LINE_WIDTH: 0.240373
G1 X136.679 Y134.849 E.00412
; WIPE_START
G1 X136.531 Y134.826 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.548 Y135.099 Z8.64 F42000
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 0.988147
G1 F2592.256
M204 S6000
G1 X139.07 Y135.162 E.10411
; LINE_WIDTH: 0.954391
G1 F2697.151
G1 X139.285 Y135.185 E.04121
; LINE_WIDTH: 0.909088
G1 F2852.034
G1 X139.489 Y135.207 E.03699
; LINE_WIDTH: 0.86497
G1 F3000
G1 X139.694 Y135.229 E.03492
; LINE_WIDTH: 0.820853
G1 X139.898 Y135.251 E.03285
; LINE_WIDTH: 0.776736
G1 X140.102 Y135.273 E.03078
; LINE_WIDTH: 0.753909
G1 X140.11 Y135.274 E.00108
; LINE_WIDTH: 0.728387
G1 X140.367 Y135.299 E.03591
; LINE_WIDTH: 0.678864
G1 X140.625 Y135.324 E.03299
; LINE_WIDTH: 0.629341
G1 X140.882 Y135.348 E.03006
; LINE_WIDTH: 0.579818
G1 X141.14 Y135.373 E.02714
; LINE_WIDTH: 0.532599
G1 X141.403 Y135.396 E.02484
; LINE_WIDTH: 0.488163
G1 X141.661 Y135.418 E.02177
; LINE_WIDTH: 0.444129
G1 X141.92 Y135.44 E.01916
; LINE_WIDTH: 0.400094
G1 X142.178 Y135.462 E.01656
; LINE_WIDTH: 0.353097
G1 X142.502 Y135.487 E.01729
; LINE_WIDTH: 0.303296
G1 X142.824 Y135.511 E.0135
; LINE_WIDTH: 0.263452
G1 X143.066 Y135.528 E.0079
; LINE_WIDTH: 0.23351
G1 X143.306 Y135.545 E.00622
; WIPE_START
G1 X143.066 Y135.528 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.501 Y127.917 Z8.64 F42000
G1 X141.955 Y120.558 Z8.64
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 0.396048
G1 F3000
M204 S6000
G1 X142.186 Y120.538 E.01462
; LINE_WIDTH: 0.356829
G1 X142.465 Y120.517 E.01511
; LINE_WIDTH: 0.317214
G1 X142.742 Y120.497 E.01248
; LINE_WIDTH: 0.277758
G1 X143.019 Y120.476 E.00998
; LINE_WIDTH: 0.238303
G1 X143.295 Y120.456 E.00748
M204 S10000
G1 X141.955 Y120.558 F42000
; LINE_WIDTH: 0.43475
G1 F3000
M204 S6000
G1 X141.722 Y120.577 E.01677
; LINE_WIDTH: 0.474682
G1 X141.488 Y120.597 E.01898
; LINE_WIDTH: 0.51572
G1 X141.254 Y120.618 E.02118
; LINE_WIDTH: 0.55706
G1 X141.017 Y120.639 E.02373
; LINE_WIDTH: 0.602476
G1 X140.76 Y120.663 E.02847
; LINE_WIDTH: 0.651879
G1 X140.499 Y120.688 E.03173
; LINE_WIDTH: 0.697281
G1 X140.295 Y120.709 E.02707
; LINE_WIDTH: 0.738391
G1 X140.09 Y120.729 E.029
; LINE_WIDTH: 0.78003
G1 X139.88 Y120.75 E.03175
; LINE_WIDTH: 0.821316
G1 X139.694 Y120.771 E.02997
; LINE_WIDTH: 0.861661
G1 X139.508 Y120.791 E.0317
; LINE_WIDTH: 0.90245
G1 F2876.235
G1 X139.317 Y120.811 E.03418
; LINE_WIDTH: 0.941922
G1 F2738.075
G1 X138.933 Y120.855 E.07249
; LINE_WIDTH: 0.979585
G1 F2618.08
G1 X138.549 Y120.899 E.07581
; WIPE_START
G1 X138.933 Y120.855 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.682 Y121.152 Z8.64 F42000
G1 Z8.24
G1 E.8 F1800
; LINE_WIDTH: 0.241061
G1 F3000
M204 S6000
G1 X136.526 Y121.175 E.00436
; LINE_WIDTH: 0.286042
G1 X136.37 Y121.199 E.00598
; LINE_WIDTH: 0.331023
G1 X136.214 Y121.223 E.0076
; LINE_WIDTH: 0.376005
G1 X136.058 Y121.247 E.00922
; LINE_WIDTH: 0.421791
G1 X135.896 Y121.272 E.01126
; LINE_WIDTH: 0.467869
G1 X135.764 Y121.295 E.01062
; LINE_WIDTH: 0.513043
G1 X135.632 Y121.317 E.012
; LINE_WIDTH: 0.558216
G1 X135.5 Y121.34 E.01338
; LINE_WIDTH: 0.60339
G1 X135.368 Y121.363 E.01476
; LINE_WIDTH: 0.648563
G1 X135.236 Y121.385 E.01614
; LINE_WIDTH: 0.693737
G1 X135.104 Y121.408 E.01752
; LINE_WIDTH: 0.74033
G1 X134.964 Y121.432 E.02013
; LINE_WIDTH: 0.787652
G1 X134.838 Y121.455 E.0195
; LINE_WIDTH: 0.835528
G1 X134.704 Y121.48 E.02218
; LINE_WIDTH: 0.868253
G1 X134.293 Y121.56 E.07165
M204 S10000
G1 X133.453 Y121.552 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.24954
G1 F1992.279
M204 S6000
G1 X133.312 Y121.552 E.03637
G1 X133.242 Y121.674 E.03638
G1 X133.312 Y121.797 E.03638
G1 X133.453 Y121.797 E.03638
G1 X133.464 Y121.778 E.00545
; WIPE_START
G1 X133.453 Y121.797 E-.02746
G1 X133.312 Y121.797 E-.18314
G1 X133.242 Y121.674 E-.18314
G1 X133.312 Y121.552 E-.18314
G1 X133.453 Y121.552 E-.18312
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.062 Y122.459 Z8.64 F42000
G1 Z8.24
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.836357
G1 F3141.668
M204 S2000
G1 X132.722 Y124.118 E.38349
G2 X132.109 Y124.518 I3.067 J5.371 E.11966
G1 X130.731 Y123.14 E.31839
G1 X130.176 Y123.598 E.11757
G1 X131.538 Y124.96 E.31465
G2 X131.016 Y125.451 I2.271 J2.935 E.11726
G1 X129.621 Y124.056 E.32235
G1 X129.066 Y124.514 E.11757
G1 X130.556 Y126.004 E.34434
G1 X130.184 Y126.645 E.12109
G1 X128.511 Y124.972 E.38668
G2 X128.342 Y125.205 I.134 J.275 E.04897
G1 X128.284 Y125.263 E.01336
G1 X128.284 Y125.758 E.08091
G1 X129.941 Y127.415 E.38294
G1 X129.885 Y127.709 E.04891
G1 X129.885 Y128.285 E.09421
G1 X129.905 Y128.391 E.01764
G1 X128.284 Y126.771 E.37455
G1 X128.284 Y127.784 E.16551
G1 X132.552 Y132.052 E.98631
G1 X132.039 Y132.551 E.11704
G1 X128.284 Y128.796 E.86773
G1 X128.284 Y129.809 E.16551
G1 X131.749 Y133.274 E.80062
; WIPE_START
M204 S6000
G1 X130.335 Y131.86 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X122.783 Y132.968 Z8.64 F42000
G1 X112.209 Y134.521 Z8.64
G1 Z8.24
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.715 J-6.607 E.44691
G1 X122.192 Y120.612 E2.65853
G2 X119.601 Y119.601 I-4.767 J8.396 E.44565
G1 X126.395 Y126.395 E1.53411
G1 X126.395 Y129.605 E.51261
G1 X119.596 Y136.404 E1.53516
G2 X122.193 Y135.389 I-2.243 J-9.571 E.44663
G1 X110.42 Y123.616 E2.65862
G3 X112.21 Y121.481 I7.609 J4.563 E.44679
; CHANGE_LAYER
; Z_HEIGHT: 8.8
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.558 E-.57275
G1 X110.874 Y122.962 E-.18725
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 16/51
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z8.8 I-.672 J1.565 P1  F42000
G1 X128.3 Y130.447 Z8.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X128.3 Y130.693 E.03928
G1 X129.085 Y131.483 E.17781
G2 X131.755 Y133.21 I7.841 J-9.19 E.50926
G2 X136.501 Y134.877 I11.392 J-24.846 E.80431
G1 X136.451 Y135.241 E.05856
G1 X124.744 Y135.241 E1.86932
M73 P56 R8
G2 X122.777 Y135.741 I.032 J4.246 E.32728
G3 X115.186 Y119.193 I-4.955 J-7.742 E5.01988
G3 X118.007 Y118.814 I2.639 J8.969 E.4563
G3 X122.779 Y120.261 I-.228 J9.346 E.80593
G2 X124.735 Y120.76 I2.038 J-3.902 E.32528
G1 X136.458 Y120.76 E1.8718
G1 X136.503 Y121.128 E.05928
G2 X131.711 Y122.811 I6.116 J25.079 E.81235
G2 X129.087 Y124.516 I5.235 J10.928 E.50096
G1 X128.3 Y125.307 E.17819
G1 X128.3 Y130.327 E.80165
M204 S10000
G1 X128.999 Y130.289 F42000
G1 F3215.099
M204 S6000
G1 X128.999 Y130.404 E.01834
G2 X131.351 Y132.214 I6.719 J-6.3 E.4759
G2 X135.582 Y133.897 I10.406 J-19.996 E.72837
G2 X143.31 Y135.365 I12.608 J-45.303 E1.25739
G2 X145.144 Y135.538 I5.866 J-52.38 E.2942
G1 X145.127 Y135.94 E.0643
G1 X124.754 Y135.94 E3.25311
G2 X123.108 Y136.358 I.022 J3.542 E.27376
G3 X118.029 Y118.114 I-5.292 J-8.355 E5.887
G3 X123.109 Y119.643 I-.245 J10.017 E.85731
G2 X124.748 Y120.06 I1.699 J-3.251 E.27248
G1 X145.136 Y120.06 E3.25541
G1 X145.153 Y120.462 E.06423
G2 X136.374 Y121.882 I3.87 J51.769 E1.42184
G2 X132.019 Y123.44 I6.34 J24.589 E.73957
G2 X129.559 Y125.034 I4.925 J10.295 E.4693
G1 X128.999 Y125.596 E.12659
G1 X128.999 Y130.169 E.7303
M204 S250
G1 X129.943 Y130.36 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X130.035 Y130.441 E.0195
G2 X131.047 Y131.218 I5.144 J-5.648 E.20399
G2 X134.875 Y132.945 I8.971 J-14.778 E.67233
G2 X141.712 Y134.459 I12.22 J-39 E1.11948
G2 X148.744 Y135.033 I9.092 J-68.021 E1.12705
G3 X146.786 Y136.64 I-1.962 J-.394 E.43796
G1 X124.763 Y136.64 E3.51651
G2 X123.439 Y136.974 I.012 J2.838 E.22024
G3 X110.336 Y135.501 I-5.621 J-9.011 E2.27141
G3 X118.051 Y117.415 I7.48 J-7.498 E4.02401
G3 X123.439 Y119.026 I-.262 J10.691 E.90867
G2 X124.761 Y119.36 I1.361 J-2.602 E.21969
G1 X146.786 Y119.36 E3.51688
G3 X148.744 Y120.97 I.001 J1.994 E.43852
G2 X137.49 Y122.324 I1.11 J56.672 E1.81297
G2 X133.042 Y123.742 I6.405 J27.778 E.74622
G2 X130.512 Y125.155 I5.081 J12.069 E.46374
G2 X129.699 Y125.885 I3.324 J4.519 E.17466
G1 X129.699 Y130.115 E.67551
G1 X129.858 Y130.275 E.036
; WIPE_START
M204 S6000
G1 X130.035 Y130.441 E-.09195
G1 X130.506 Y130.841 E-.23496
G1 X131.047 Y131.218 E-.25049
G1 X131.46 Y131.464 E-.1826
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


G1 X131.838 Y134.541 F42000
G1 Z8.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X131.931 Y134.059 E.07831
G3 X130.227 Y133.173 I6.604 J-14.781 E.30682
; LINE_WIDTH: 0.835365
G1 F3146.028
G1 X130.012 Y133.059 E.03972
; LINE_WIDTH: 0.8661
G1 F3016.399
G1 X129.798 Y132.944 E.04143
; LINE_WIDTH: 0.899692
G1 F2886.41
G1 X129.675 Y132.881 E.0245
; LINE_WIDTH: 0.936142
G1 F2757.471
G1 X129.553 Y132.818 E.02565
; LINE_WIDTH: 0.972592
G1 F2639.559
G1 X129.43 Y132.754 E.02679
; LINE_WIDTH: 0.967123
G1 F2656.603
G1 X129.31 Y132.633 E.03305
; LINE_WIDTH: 0.919736
G1 F2814.052
G1 X129.19 Y132.511 E.0312
; LINE_WIDTH: 0.872348
G1 F2991.34
G1 X129.07 Y132.389 E.02935
; LINE_WIDTH: 0.824961
G1 F3192.469
G1 X128.95 Y132.267 E.0275
; LINE_WIDTH: 0.799507
G1 F3312.087
G1 X128.609 Y131.98 E.06908
; LINE_WIDTH: 0.813269
G1 F3246.32
G1 X128.148 Y131.539 E.10085
; LINE_WIDTH: 0.840848
G1 F3122.091
G1 X127.688 Y131.099 E.10486
G1 X127.614 Y130.897 E.03534
; LINE_WIDTH: 0.796198
G1 F3328.298
G1 X127.612 Y125.162 E.88449
; LINE_WIDTH: 0.813115
G1 F3247.046
G1 X127.639 Y125.041 E.0196
; LINE_WIDTH: 0.849783
G1 F3083.858
G1 X127.667 Y124.921 E.02063
G1 X127.688 Y124.901 E.00471
; LINE_WIDTH: 0.844517
G1 F3106.276
G1 X128.149 Y124.459 E.10561
; LINE_WIDTH: 0.813634
G1 F3244.612
G3 X129.083 Y123.605 I9.99 J9.987 E.20031
; LINE_WIDTH: 0.85006
G1 F3082.688
G1 X129.17 Y123.516 E.02083
; LINE_WIDTH: 0.890065
G1 F2922.505
G1 X129.257 Y123.426 E.02197
; LINE_WIDTH: 0.93007
G1 F2778.147
G1 X129.344 Y123.336 E.02311
; LINE_WIDTH: 0.970075
G1 F2647.378
G1 X129.431 Y123.246 E.02426
; LINE_WIDTH: 0.968817
G1 F2651.301
G1 X129.55 Y123.189 E.0256
; LINE_WIDTH: 0.926297
M73 P57 R8
G1 F2791.148
G1 X129.67 Y123.132 E.02432
; LINE_WIDTH: 0.883777
G1 F2946.569
G1 X129.789 Y123.075 E.02304
; LINE_WIDTH: 0.820442
G1 F3213.071
G1 X129.908 Y123.018 E.02113
G3 X131.931 Y121.941 I9.111 J14.684 E.36632
G1 X131.837 Y121.456 E.079
G1 X129.04 Y121.454 E.44687
G1 X129.131 Y122.054 E.09703
; LINE_WIDTH: 0.841257
G1 F3120.319
G1 X129.082 Y122.174 E.02124
; LINE_WIDTH: 0.883777
G1 F2946.569
G1 X129.033 Y122.293 E.02249
; LINE_WIDTH: 0.926297
G1 F2791.148
G1 X128.984 Y122.412 E.02375
; LINE_WIDTH: 0.986323
G1 F2597.715
G1 X128.934 Y122.532 E.02552
G1 X128.707 Y122.635 E.04945
G1 X128.707 Y122.913 E.05489
; LINE_WIDTH: 0.966442
G1 F2658.742
G1 X128.638 Y123.007 E.02255
; LINE_WIDTH: 0.917792
G1 F2820.91
G1 X128.569 Y123.101 E.02125
; LINE_WIDTH: 0.869142
G1 F3004.146
G1 X128.5 Y123.196 E.01995
; LINE_WIDTH: 0.802769
G1 F3296.259
G1 X128.43 Y123.29 E.01818
G1 X128.156 Y123.517 E.05559
; LINE_WIDTH: 0.813357
G1 F3245.91
G1 X127.673 Y123.936 E.10106
; LINE_WIDTH: 0.850841
G1 F3079.39
G2 X126.972 Y124.546 I49.175 J57.213 E.15482
; LINE_WIDTH: 0.85116
G1 F3078.049
G1 X126.954 Y124.854 E.0515
; LINE_WIDTH: 0.797118
G1 F3323.776
G1 X126.936 Y125.162 E.04769
G1 X126.936 Y130.838 E.87661
; LINE_WIDTH: 0.81444
G1 F3240.849
G1 X126.954 Y131.146 E.04885
; LINE_WIDTH: 0.857554
G1 F3051.357
G1 X126.972 Y131.453 E.05188
G1 X127.19 Y131.645 E.04874
; LINE_WIDTH: 0.844315
G1 F3107.145
G1 X127.671 Y132.063 E.10536
; LINE_WIDTH: 0.813538
G1 F3245.063
G3 X128.537 Y132.82 I-36.593 J42.643 E.18196
; LINE_WIDTH: 0.850177
G1 F3082.192
G1 X128.579 Y132.888 E.0133
; LINE_WIDTH: 0.890537
G1 F2920.712
G1 X128.622 Y132.956 E.01404
; LINE_WIDTH: 0.930897
G1 F2775.311
G1 X128.664 Y133.023 E.01477
; LINE_WIDTH: 0.990471
G1 F2585.333
G1 X128.707 Y133.091 E.01586
G1 X128.707 Y133.366 E.05469
G1 X128.993 Y133.515 E.06392
; LINE_WIDTH: 0.975213
G1 F2631.468
G1 X129.027 Y133.655 E.02823
; LINE_WIDTH: 0.930866
G1 F2775.418
G1 X129.06 Y133.796 E.02677
; LINE_WIDTH: 0.886518
G1 F2936.029
G1 X129.094 Y133.937 E.0253
; LINE_WIDTH: 0.820971
G1 F3210.645
G1 X129.128 Y134.077 E.02314
G1 X129.039 Y134.541 E.07547
G1 X131.718 Y134.541 E.42831
M204 S10000
G1 X129.899 Y133.722 F42000
; LINE_WIDTH: 0.891477
G1 F2917.153
M204 S6000
G1 X129.802 Y133.722 E.01696
G1 X129.754 Y133.805 E.01697
G1 X129.802 Y133.889 E.01697
G1 X129.875 Y133.889 E.01281
; WIPE_START
G1 X129.802 Y133.889 E-.15285
G1 X129.754 Y133.805 E-.20238
G1 X129.802 Y133.722 E-.20239
G1 X129.899 Y133.722 E-.20237
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.902 Y126.089 Z9.2 F42000
G1 X129.903 Y122.107 Z9.2
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.893117
G1 F2910.963
M204 S6000
G1 X129.806 Y122.107 E.01704
G1 X129.758 Y122.191 E.01704
G1 X129.806 Y122.274 E.01704
G1 X129.88 Y122.274 E.01291
M204 S10000
G1 X132.57 Y121.561 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.854185
G1 F3000
M204 S6000
G1 X132.88 Y121.501 E.05285
; LINE_WIDTH: 0.8064
G1 X133.19 Y121.441 E.04941
; LINE_WIDTH: 0.780012
G1 X133.203 Y121.438 E.0021
; LINE_WIDTH: 0.754092
G1 X133.34 Y121.415 E.02002
; LINE_WIDTH: 0.707282
G1 X133.476 Y121.392 E.01854
; LINE_WIDTH: 0.660473
G1 X133.613 Y121.368 E.01706
; LINE_WIDTH: 0.613663
G1 X133.749 Y121.345 E.01559
; LINE_WIDTH: 0.566853
G1 X133.886 Y121.321 E.01411
; LINE_WIDTH: 0.520043
G1 X134.022 Y121.298 E.01263
; LINE_WIDTH: 0.473234
G1 X134.158 Y121.275 E.01115
; LINE_WIDTH: 0.425867
G1 X134.323 Y121.249 E.01162
; LINE_WIDTH: 0.379155
G1 X134.482 Y121.225 E.00951
; LINE_WIDTH: 0.333273
G1 X134.641 Y121.2 E.00782
; LINE_WIDTH: 0.287391
G1 X134.8 Y121.176 E.00614
; LINE_WIDTH: 0.24151
G1 X134.959 Y121.151 E.00445
; WIPE_START
G1 X134.8 Y121.176 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.827 Y120.898 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.982391
G1 F2609.561
M204 S6000
G1 X137.181 Y120.858 E.07009
; LINE_WIDTH: 0.951539
G1 F2706.402
G1 X137.535 Y120.818 E.06759
; LINE_WIDTH: 0.911787
G1 F2842.309
G1 X137.76 Y120.794 E.04075
; LINE_WIDTH: 0.863657
G1 F3000
G1 X137.98 Y120.77 E.03757
; LINE_WIDTH: 0.815977
G1 X138.2 Y120.746 E.03516
; LINE_WIDTH: 0.774599
G1 X138.374 Y120.728 E.02611
; LINE_WIDTH: 0.740155
G1 X138.543 Y120.711 E.024
; LINE_WIDTH: 0.706234
G1 X138.712 Y120.694 E.02269
; LINE_WIDTH: 0.669213
G1 X138.922 Y120.674 E.02643
; LINE_WIDTH: 0.629423
G1 X139.129 Y120.655 E.02418
; LINE_WIDTH: 0.589908
G1 X139.336 Y120.635 E.0223
; LINE_WIDTH: 0.552593
G1 X139.536 Y120.617 E.01979
; LINE_WIDTH: 0.517812
G1 X139.732 Y120.6 E.01789
; LINE_WIDTH: 0.483328
G1 X139.929 Y120.583 E.01634
; LINE_WIDTH: 0.442163
G1 X140.216 Y120.559 E.02116
; LINE_WIDTH: 0.394473
G1 X140.501 Y120.535 E.01793
; LINE_WIDTH: 0.351556
G1 X140.77 Y120.515 E.01423
; LINE_WIDTH: 0.313523
G1 X141.036 Y120.495 E.01179
; LINE_WIDTH: 0.275648
G1 X141.303 Y120.475 E.00948
; LINE_WIDTH: 0.237772
G1 X141.57 Y120.456 E.00717
; WIPE_START
G1 X141.303 Y120.475 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.494 Y120.247 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 1.1354
G1 F2216.265
M204 S6000
G1 X146.713 Y120.206 E.28243
; LINE_WIDTH: 1.09502
G1 F2308.055
G3 X147.055 Y120.213 I.107 J3.088 E.07607
; LINE_WIDTH: 1.04361
G1 F2436.564
G3 X147.192 Y120.23 I-.216 J2.388 E.0292
; LINE_WIDTH: 1.00453
G1 F2544.244
G1 X147.264 Y120.241 E.0147
; LINE_WIDTH: 0.974522
G1 F2633.596
G1 X148.135 Y120.41 E.17296
; WIPE_START
G1 X147.264 Y120.241 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.696 Y127.862 Z9.2 F42000
G1 X148.134 Y135.59 Z9.2
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.968771
G1 F2651.446
M204 S6000
G1 X147.281 Y135.756 E.16818
; LINE_WIDTH: 1.00118
G1 F2553.915
G1 X147.189 Y135.771 E.0189
; LINE_WIDTH: 1.04505
G1 F2432.76
G3 X147.052 Y135.787 I-.342 J-2.365 E.02891
; LINE_WIDTH: 1.08858
G1 F2323.414
G3 X146.853 Y135.796 I-.219 J-2.788 E.04416
; LINE_WIDTH: 1.11851
G1 F2253.761
G1 X146.363 Y135.783 E.11164
; LINE_WIDTH: 1.14447
G1 F2196.63
G1 X145.485 Y135.754 E.2052
; WIPE_START
G1 X146.363 Y135.783 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.569 Y135.545 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.235571
G1 F3000
M204 S6000
G1 X141.308 Y135.526 E.00688
; LINE_WIDTH: 0.269612
G1 X141.046 Y135.507 E.00894
; LINE_WIDTH: 0.307741
G1 X140.773 Y135.486 E.01174
; LINE_WIDTH: 0.350021
G1 X140.498 Y135.465 E.01448
; LINE_WIDTH: 0.393664
G1 X140.234 Y135.443 E.01653
; LINE_WIDTH: 0.438479
G1 X139.97 Y135.42 E.01924
; LINE_WIDTH: 0.483293
G1 X139.706 Y135.398 E.02195
; LINE_WIDTH: 0.528511
G1 X139.437 Y135.375 E.02513
; LINE_WIDTH: 0.571463
G1 X139.228 Y135.355 E.02165
; LINE_WIDTH: 0.611635
G1 X139.018 Y135.335 E.02358
; LINE_WIDTH: 0.651806
G1 X138.809 Y135.315 E.0255
; LINE_WIDTH: 0.691978
G1 X138.6 Y135.295 E.02743
; LINE_WIDTH: 0.732876
G1 X138.383 Y135.274 E.03045
; LINE_WIDTH: 0.776147
G1 X138.176 Y135.251 E.03117
; LINE_WIDTH: 0.820886
G1 X137.969 Y135.229 E.0333
; LINE_WIDTH: 0.865625
G1 X137.762 Y135.207 E.03542
; LINE_WIDTH: 0.910365
G1 F2847.424
G1 X137.555 Y135.184 E.03755
; LINE_WIDTH: 0.956116
G1 F2691.585
G1 X137.338 Y135.161 E.04152
; LINE_WIDTH: 0.988922
G1 F2589.943
G1 X136.824 Y135.1 E.1027
; WIPE_START
G1 X137.338 Y135.161 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.956 Y134.849 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; LINE_WIDTH: 0.240219
G1 F3000
M204 S6000
G1 X134.81 Y134.826 E.00407
; LINE_WIDTH: 0.283264
G1 X134.663 Y134.803 E.00553
; LINE_WIDTH: 0.326309
G1 X134.516 Y134.781 E.00698
; LINE_WIDTH: 0.369354
G1 X134.369 Y134.758 E.00844
; LINE_WIDTH: 0.412399
G1 X134.223 Y134.735 E.0099
; LINE_WIDTH: 0.456348
G1 X134.07 Y134.711 E.01187
; LINE_WIDTH: 0.501911
G1 X133.937 Y134.688 E.01173
; LINE_WIDTH: 0.54778
G1 X133.804 Y134.665 E.01314
; LINE_WIDTH: 0.593649
G1 X133.672 Y134.643 E.01455
; LINE_WIDTH: 0.639518
G1 X133.539 Y134.62 E.01596
; LINE_WIDTH: 0.685386
G1 X133.406 Y134.597 E.01737
; LINE_WIDTH: 0.731255
G1 X133.273 Y134.574 E.01878
; LINE_WIDTH: 0.777124
G1 X133.141 Y134.551 E.02018
; LINE_WIDTH: 0.802502
G1 X133.127 Y134.548 E.00211
; LINE_WIDTH: 0.822899
G1 X132.849 Y134.495 E.04553
; LINE_WIDTH: 0.858823
G1 X132.57 Y134.441 E.04786
M204 S10000
G1 X112.211 Y121.48 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.42 Y123.616 I6.645 J7.394 E.44646
G1 X122.193 Y135.389 E2.65863
G3 X119.596 Y136.404 I-4.848 J-8.578 E.44664
G1 X126.248 Y129.752 E1.50197
G1 X126.248 Y126.248 E.55958
G1 X119.601 Y119.601 E1.50084
G3 X122.192 Y120.612 I-2.179 J9.415 E.44559
G1 X110.419 Y132.385 E2.65853
G2 X112.209 Y134.521 I7.5 J-4.468 E.44691
; CHANGE_LAYER
; Z_HEIGHT: 9.36
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.183 Y133.476 E-.55664
G1 X110.876 Y133.037 E-.20337
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 17/51
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z9.36 I.05 J1.703 P1  F42000
G1 X128.682 Y132.511 Z9.36
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.011 Y133.2 E.23901
G2 X134.775 Y134.878 I11.199 J-24.205 E.8078
G1 X134.726 Y135.241 E.05847
G1 X124.744 Y135.241 E1.59375
G2 X122.777 Y135.741 I.032 J4.246 E.32737
G3 X116.333 Y118.93 I-4.956 J-7.741 E5.20794
G3 X118.016 Y118.814 I1.521 J9.83 E.26968
G3 X122.779 Y120.261 I-.237 J9.346 E.80448
G2 X124.735 Y120.76 I2.038 J-3.902 E.32524
G1 X134.733 Y120.76 E1.59651
G1 X134.779 Y121.128 E.0593
G2 X128.482 Y123.594 I5.89 J24.319 E1.08312
G1 X128.482 Y132.407 E1.40725
G1 X128.575 Y132.456 E.0169
M204 S10000
G1 X129.181 Y131.869 F42000
G1 F3215.099
M204 S6000
G1 X129.181 Y131.982 E.01803
G2 X133.664 Y133.84 I10.71 J-19.499 E.7764
G2 X140.452 Y135.229 I12.43 J-43.488 E1.10743
G2 X143.416 Y135.538 I8.474 J-66.756 E.4758
G1 X143.399 Y135.94 E.06428
G1 X124.754 Y135.94 E2.97712
G2 X123.108 Y136.358 I.022 J3.542 E.27381
G3 X118.038 Y118.115 I-5.292 J-8.355 E5.88834
G3 X123.109 Y119.643 I-.254 J10.017 E.85581
G2 X124.748 Y120.06 I1.699 J-3.252 E.27247
G1 X143.414 Y120.06 E2.98043
G1 X143.431 Y120.462 E.06424
G2 X134.668 Y121.877 I3.547 J49.795 E1.41921
G2 X130.308 Y123.434 I6.386 J24.773 E.74013
G1 X129.181 Y124.019 E.2028
G1 X129.181 Y131.749 E1.23426
M204 S250
G1 X129.881 Y131.556 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X133.864 Y133.169 I9.803 J-18.482 E.68733
G2 X140.543 Y134.535 I12.227 J-42.8 E1.08964
G2 X148.738 Y135.059 I8.329 J-65.909 E1.31204
G3 X146.786 Y136.64 I-1.947 J-.408 E.43414
G1 X124.763 Y136.64 E3.51652
G2 X123.439 Y136.975 I.012 J2.838 E.22027
G3 X118.061 Y117.415 I-5.623 J-8.973 E6.29767
G3 X123.439 Y119.026 I-.271 J10.69 E.90716
G2 X124.761 Y119.36 I1.361 J-2.601 E.21969
G1 X146.787 Y119.36 E3.51691
G3 X148.738 Y120.942 I.001 J1.994 E.43397
G2 X136.808 Y122.092 I-.193 J60.453 E1.91695
G2 X131.341 Y123.732 I6.118 J30.327 E.91254
G2 X129.881 Y124.444 I6.18 J14.525 E.25954
G1 X129.881 Y125.817 E.21921
G1 X129.881 Y130.183 E.69721
G1 X129.881 Y131.436 E.20007
; WIPE_START
M204 S6000
G1 X130.623 Y131.941 E-.34109
G1 X131.328 Y132.262 E-.29418
G1 X131.632 Y132.385 E-.12474
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


G1 X131.126 Y134.494 F42000
G1 Z9.36
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.822553
G1 F3000
M204 S6000
G1 X131.405 Y134.549 E.04554
; LINE_WIDTH: 0.801911
G1 X131.419 Y134.551 E.00222
; LINE_WIDTH: 0.775816
G1 X131.555 Y134.575 E.02067
; LINE_WIDTH: 0.728798
G1 X131.691 Y134.598 E.01919
; LINE_WIDTH: 0.68178
G1 X131.828 Y134.622 E.01771
; LINE_WIDTH: 0.634761
G1 X131.964 Y134.645 E.01622
; LINE_WIDTH: 0.587743
G1 X132.1 Y134.669 E.01474
; LINE_WIDTH: 0.540725
G1 X132.236 Y134.692 E.01326
; LINE_WIDTH: 0.493706
G1 X132.372 Y134.716 E.01178
; LINE_WIDTH: 0.469207
G1 X132.379 Y134.717 E.0005
; LINE_WIDTH: 0.443237
G1 X132.55 Y134.743 E.01277
; LINE_WIDTH: 0.393313
G1 X132.721 Y134.77 E.0108
; LINE_WIDTH: 0.343388
G1 X132.892 Y134.796 E.00882
; LINE_WIDTH: 0.293464
G1 X133.063 Y134.823 E.00685
; LINE_WIDTH: 0.243539
M73 P57 R7
G1 X133.235 Y134.849 E.00488
; WIPE_START
G1 X133.063 Y134.823 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.098 Y135.098 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.991197
G1 F2583.177
M204 S6000
G1 X135.597 Y135.159 E.09978
; LINE_WIDTH: 0.959433
G1 F2680.946
G1 X135.82 Y135.183 E.04288
; LINE_WIDTH: 0.912542
G1 F2839.602
G1 X136.031 Y135.206 E.03841
; LINE_WIDTH: 0.866883
G1 F3000
G1 X136.242 Y135.229 E.0362
; LINE_WIDTH: 0.821225
G1 X136.453 Y135.251 E.03399
; LINE_WIDTH: 0.775566
G1 X136.665 Y135.274 E.03178
; LINE_WIDTH: 0.73147
G1 X136.886 Y135.295 E.03097
; LINE_WIDTH: 0.689842
G1 X137.099 Y135.316 E.02786
; LINE_WIDTH: 0.648949
G1 X137.312 Y135.336 E.02586
; LINE_WIDTH: 0.608056
G1 X137.526 Y135.357 E.02386
; LINE_WIDTH: 0.567163
G1 X137.739 Y135.377 E.02186
; LINE_WIDTH: 0.523623
G1 X138.011 Y135.4 E.02516
; LINE_WIDTH: 0.477978
G1 X138.279 Y135.423 E.02192
; LINE_WIDTH: 0.432737
M73 P58 R7
G1 X138.546 Y135.446 E.01915
; LINE_WIDTH: 0.387497
G1 X138.814 Y135.468 E.01638
; LINE_WIDTH: 0.347101
G1 X139.045 Y135.486 E.01197
; LINE_WIDTH: 0.311718
G1 X139.273 Y135.504 E.01003
; LINE_WIDTH: 0.275159
G1 X139.568 Y135.524 E.01043
; LINE_WIDTH: 0.237412
G1 X139.861 Y135.545 E.00786
; WIPE_START
G1 X139.568 Y135.524 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.757 Y135.754 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 1.13875
G1 F2208.971
M204 S6000
G1 X144.881 Y135.791 E.26133
; LINE_WIDTH: 1.10493
G1 F2284.845
G1 X145.427 Y135.805 E.12269
; LINE_WIDTH: 1.07775
G1 F2349.701
G1 X145.965 Y135.818 E.11754
; LINE_WIDTH: 1.04939
G1 F2421.406
G1 X146.776 Y135.833 E.17209
; LINE_WIDTH: 1.01991
G1 F2500.731
G2 X147.06 Y135.822 I.041 J-2.495 E.05834
; LINE_WIDTH: 0.975822
G1 F2629.594
G2 X147.199 Y135.803 I-.247 J-2.429 E.02747
; LINE_WIDTH: 0.934234
G1 F2763.934
G1 X147.295 Y135.786 E.01806
; LINE_WIDTH: 0.9033
G1 F2873.112
G1 X148.117 Y135.613 E.15014
; WIPE_START
G1 X147.295 Y135.786 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.701 Y128.164 Z9.76 F42000
G1 X148.115 Y120.382 Z9.76
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.909015
G1 F2852.296
M204 S6000
G1 X147.277 Y120.211 E.15401
; LINE_WIDTH: 0.938357
G1 F2750.006
G1 X147.203 Y120.198 E.01395
; LINE_WIDTH: 0.974757
G1 F2632.871
G2 X147.073 Y120.181 I-.358 J2.238 E.02563
; LINE_WIDTH: 1.02037
G1 F2499.45
G2 X146.775 Y120.168 I-.283 J3.113 E.06117
; LINE_WIDTH: 1.0431
G1 F2437.91
G1 X146.32 Y120.175 E.09587
; LINE_WIDTH: 1.06467
G1 F2382.241
G1 X145.674 Y120.19 E.13914
; LINE_WIDTH: 1.09511
G1 F2307.856
G1 X145.02 Y120.205 E.14572
; LINE_WIDTH: 1.13453
G1 F2218.162
G1 X143.772 Y120.246 E.28894
; WIPE_START
G1 X145.02 Y120.205 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.853 Y120.456 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.242703
G1 F3000
M204 S6000
G1 X139.51 Y120.481 E.00962
; LINE_WIDTH: 0.290941
G1 X139.167 Y120.506 E.01341
; LINE_WIDTH: 0.33934
G1 X138.821 Y120.532 E.01732
; LINE_WIDTH: 0.382679
G1 X138.593 Y120.551 E.01371
; LINE_WIDTH: 0.420686
G1 X138.365 Y120.57 E.01569
; LINE_WIDTH: 0.458825
G1 X138.136 Y120.589 E.01781
; LINE_WIDTH: 0.498934
G1 X137.897 Y120.61 E.02072
; LINE_WIDTH: 0.541162
G1 X137.654 Y120.631 E.02335
; LINE_WIDTH: 0.585581
G1 X137.412 Y120.654 E.02587
; LINE_WIDTH: 0.631844
G1 X137.169 Y120.677 E.02844
; LINE_WIDTH: 0.678387
G1 X136.924 Y120.701 E.0314
; LINE_WIDTH: 0.721866
G1 X136.724 Y120.721 E.02754
; LINE_WIDTH: 0.762494
G1 X136.52 Y120.741 E.03015
; LINE_WIDTH: 0.803736
G1 X136.329 Y120.762 E.02989
; LINE_WIDTH: 0.845005
G1 X136.139 Y120.783 E.0317
; LINE_WIDTH: 0.886274
G1 F2936.965
G1 X135.948 Y120.803 E.0335
; LINE_WIDTH: 0.928
G1 F2785.264
G1 X135.753 Y120.824 E.03611
; LINE_WIDTH: 0.973419
G1 F2637.001
G1 X135.103 Y120.898 E.12742
; WIPE_START
G1 X135.753 Y120.824 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.236 Y121.151 Z9.76 F42000
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.242023
G1 F3000
M204 S6000
G1 X133.074 Y121.176 E.00456
; LINE_WIDTH: 0.288893
G1 X132.912 Y121.201 E.00632
; LINE_WIDTH: 0.335762
G1 X132.749 Y121.226 E.00807
; LINE_WIDTH: 0.382632
G1 X132.587 Y121.251 E.00982
; LINE_WIDTH: 0.430406
G1 X132.419 Y121.277 E.01206
; LINE_WIDTH: 0.477411
G1 X132.289 Y121.3 E.01074
; LINE_WIDTH: 0.522308
G1 X132.159 Y121.322 E.01209
; LINE_WIDTH: 0.567204
G1 X132.029 Y121.345 E.01344
; LINE_WIDTH: 0.612101
G1 X131.899 Y121.367 E.01479
; LINE_WIDTH: 0.656998
G1 X131.77 Y121.389 E.01614
; LINE_WIDTH: 0.701895
G1 X131.64 Y121.412 E.01749
; LINE_WIDTH: 0.746792
G1 X131.51 Y121.434 E.01884
; LINE_WIDTH: 0.791689
G1 X131.38 Y121.457 E.02019
; LINE_WIDTH: 0.816719
G1 X131.366 Y121.459 E.00228
; LINE_WIDTH: 0.833582
G1 X131.106 Y121.51 E.04299
; LINE_WIDTH: 0.862125
G1 X130.847 Y121.56 E.04471
M204 S10000
G1 X128.827 Y121.977 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.921877
G1 F2806.536
M204 S6000
G1 X128.854 Y122.142 E.03059
G3 X128.672 Y122.649 I-.962 J-.059 E.09988
G3 X130.151 Y121.911 I8.041 J14.27 E.3023
G1 X130.073 Y121.511 E.07469
G1 X128.53 Y121.511 E.28224
G1 X128.548 Y121.569 E.01119
G1 X128.663 Y121.657 E.02645
G1 X128.772 Y121.87 E.04385
M204 S10000
G1 X127.748 Y123.912 F42000
; LINE_WIDTH: 0.887142
G1 F2933.641
M204 S6000
G2 X126.984 Y124.546 I21.892 J27.172 E.1738
G1 X126.983 Y131.453 E1.2088
G1 X127.748 Y132.088 E.1739
G1 X127.748 Y124.032 E1.40983
; WIPE_START
G1 X127.748 Y126.032 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.771 Y133.391 Z9.76 F42000
G1 X130.073 Y134.49 Z9.76
G1 Z9.36
G1 E.8 F1800
; LINE_WIDTH: 0.921967
G1 F2806.221
M204 S6000
G1 X130.151 Y134.089 E.07467
G3 X128.672 Y133.352 I12.979 J-27.877 E.30221
G3 X128.816 Y134.09 I-.696 J.518 E.14231
G1 X128.663 Y134.345 E.0543
G1 X128.539 Y134.452 E.03001
G1 X128.534 Y134.49 E.00701
G1 X129.953 Y134.49 E.25955
M204 S10000
G1 X130.847 Y134.44 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.858705
G1 F3000
M204 S6000
G1 X131.126 Y134.494 E.04788
M204 S10000
G1 X112.209 Y134.521 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.713 J-6.606 E.44689
G1 X122.192 Y120.612 E2.65853
G2 X119.602 Y119.602 I-4.77 J8.408 E.44553
G1 X126.248 Y126.248 E1.50078
G1 X126.248 Y129.752 E.55958
G1 X119.596 Y136.404 E1.50199
G2 X122.193 Y135.389 I-2.124 J-9.266 E.44678
G1 X110.419 Y123.615 E2.65865
G3 X112.211 Y121.481 I8.448 J5.271 E.44645
; CHANGE_LAYER
; Z_HEIGHT: 9.92
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57281
G1 X110.875 Y122.962 E-.18719
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 18/51
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z9.92 I-.86 J1.471 P1  F42000
G1 X128.84 Y133.466 Z9.92
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.943 Y133.904 E.18957
G2 X133.051 Y134.871 I10.573 J-28.484 E.51994
G1 X133.006 Y135.241 E.05938
G1 X124.744 Y135.241 E1.31913
G2 X122.777 Y135.741 I.032 J4.246 E.32739
G3 X117.872 Y118.811 I-4.956 J-7.74 E5.45457
G1 X118.027 Y118.815 E.0247
G3 X122.775 Y120.259 I-.257 J9.375 E.80206
G2 X124.735 Y120.76 I2.041 J-3.899 E.32584
G1 X133.009 Y120.76 E1.32121
G1 X133.054 Y121.129 E.05932
G2 X128.663 Y122.606 I7.394 J29.235 E.74043
G1 X128.663 Y133.396 E1.72281
G1 X128.728 Y133.421 E.01114
M204 S10000
G1 X129.451 Y132.957 F42000
G1 F3215.099
M204 S6000
G1 X130.193 Y133.242 E.12687
G2 X135.083 Y134.623 I11.105 J-29.976 E.81225
G2 X141.699 Y135.538 I11.004 J-55.211 E1.06706
G1 X141.682 Y135.94 E.06432
G1 X124.754 Y135.94 E2.70305
G2 X123.108 Y136.358 I.022 J3.542 E.27385
G3 X118.049 Y118.115 I-5.292 J-8.355 E5.88993
G3 X123.107 Y119.642 I-.277 J10.057 E.85361
G2 X124.748 Y120.06 I1.701 J-3.249 E.27284
G1 X141.691 Y120.06 E2.70537
G1 X141.708 Y120.462 E.06426
G2 X132.962 Y121.873 I3.861 J51.757 E1.4163
G2 X129.363 Y123.079 I7.011 J26.878 E.60649
G1 X129.363 Y132.897 E1.56757
M204 S250
G1 X130.063 Y132.448 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X135.225 Y133.938 I11.304 J-29.476 E.85886
G2 X146.21 Y135.053 I11.588 J-59.502 E1.76553
G2 X148.742 Y135.042 I.913 J-84.007 E.40435
G3 X146.786 Y136.64 I-1.96 J-.403 E.4364
G1 X124.763 Y136.64 E3.51654
G2 X123.439 Y136.975 I.012 J2.837 E.22032
G3 X118.071 Y117.416 I-5.623 J-8.973 E6.29926
G3 X123.438 Y119.026 I-.297 J10.741 E.90517
G2 X124.761 Y119.36 I1.361 J-2.599 E.21985
G1 X146.787 Y119.36 E3.51693
G3 X148.741 Y120.957 I-.008 J2.004 E.43599
G2 X136.206 Y121.873 I-1.587 J64.562 E2.01009
G2 X130.063 Y123.553 I5.492 J32.15 E1.01847
G1 X130.063 Y124.441 E.14182
G1 X130.063 Y131.56 E1.13667
G1 X130.063 Y132.328 E.1227
; WIPE_START
M204 S6000
G1 X131.282 Y132.898 E-.5112
G1 X131.906 Y133.095 E-.2488
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


G1 X131.512 Y134.849 F42000
G1 Z9.92
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.24292
G1 F3000
M204 S6000
G1 X131.344 Y134.823 E.00475
; LINE_WIDTH: 0.291607
G1 X131.177 Y134.797 E.00663
; LINE_WIDTH: 0.340294
G1 X131.009 Y134.771 E.00852
; LINE_WIDTH: 0.388981
G1 X130.841 Y134.746 E.0104
; LINE_WIDTH: 0.437668
G1 X130.674 Y134.72 E.01229
; LINE_WIDTH: 0.463007
G1 X130.668 Y134.719 E.00048
; LINE_WIDTH: 0.487728
G1 X130.53 Y134.695 E.0117
; LINE_WIDTH: 0.535151
G1 X130.393 Y134.671 E.01321
; LINE_WIDTH: 0.582573
G1 X130.255 Y134.648 E.01472
; LINE_WIDTH: 0.629996
G1 X130.118 Y134.624 E.01623
; LINE_WIDTH: 0.677418
G1 X129.98 Y134.6 E.01774
; LINE_WIDTH: 0.724841
G1 X129.843 Y134.577 E.01925
; LINE_WIDTH: 0.772263
G1 X129.705 Y134.553 E.02076
; LINE_WIDTH: 0.798392
G1 X129.692 Y134.55 E.00208
; LINE_WIDTH: 0.821516
G1 X129.397 Y134.494 E.04807
; LINE_WIDTH: 0.862953
G1 X129.102 Y134.437 E.05091
; WIPE_START
G1 X129.397 Y134.494 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.376 Y135.098 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.992514
G1 F2579.279
M204 S6000
G1 X133.861 Y135.157 E.09722
; LINE_WIDTH: 0.96196
G1 F2672.898
G1 X134.087 Y135.182 E.04369
; LINE_WIDTH: 0.914313
G1 F2833.267
G1 X134.301 Y135.205 E.0391
; LINE_WIDTH: 0.867926
G1 F3000
G1 X134.516 Y135.228 E.03681
; LINE_WIDTH: 0.821538
G1 X134.73 Y135.251 E.03453
; LINE_WIDTH: 0.775151
G1 X134.945 Y135.275 E.03225
; LINE_WIDTH: 0.730342
G1 X135.17 Y135.296 E.03148
; LINE_WIDTH: 0.688007
G1 X135.387 Y135.317 E.02828
; LINE_WIDTH: 0.646416
G1 X135.605 Y135.338 E.02621
; LINE_WIDTH: 0.604824
G1 X135.822 Y135.359 E.02414
; LINE_WIDTH: 0.563233
M73 P59 R7
G1 X136.039 Y135.379 E.02207
; LINE_WIDTH: 0.519056
G1 X136.316 Y135.403 E.02529
; LINE_WIDTH: 0.472807
G1 X136.588 Y135.426 E.02197
; LINE_WIDTH: 0.426963
G1 X136.86 Y135.449 E.01912
; LINE_WIDTH: 0.381119
G1 X137.133 Y135.472 E.01626
; LINE_WIDTH: 0.344038
G1 X137.316 Y135.486 E.0094
; LINE_WIDTH: 0.315874
G1 X137.498 Y135.5 E.00815
; LINE_WIDTH: 0.28099
G1 X137.818 Y135.522 E.01179
; LINE_WIDTH: 0.239356
G1 X138.138 Y135.545 E.0087
; WIPE_START
G1 X137.818 Y135.522 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.04 Y135.754 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 1.13722
G1 F2212.29
M204 S6000
G1 X143.205 Y135.792 E.27038
; LINE_WIDTH: 1.09673
G1 F2304.024
G1 X143.942 Y135.812 E.16436
; LINE_WIDTH: 1.05496
G1 F2406.977
G1 X145.106 Y135.834 E.24815
; LINE_WIDTH: 1.01388
G1 F2517.606
G2 X146.931 Y135.845 I1.247 J-57.798 E.37219
; LINE_WIDTH: 0.972828
G1 F2638.83
G2 X147.156 Y135.822 I-.139 J-2.508 E.04399
; LINE_WIDTH: 0.928846
G1 F2782.349
G1 X147.252 Y135.805 E.01808
; LINE_WIDTH: 0.883238
G1 F2948.65
G2 X148.119 Y135.61 I-2.884 J-14.834 E.1548
; WIPE_START
G1 X147.252 Y135.805 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.68 Y128.185 Z10.32 F42000
G1 X148.118 Y120.387 Z10.32
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.888004
G1 F2930.349
M204 S6000
G2 X147.25 Y120.194 I-3.589 J14.158 E.15586
; LINE_WIDTH: 0.932728
G1 F2769.057
G1 X147.135 Y120.176 E.02157
; LINE_WIDTH: 0.972107
G1 F2641.061
G2 X146.962 Y120.158 I-.318 J2.325 E.03391
; LINE_WIDTH: 1.00668
G1 F2538.068
G2 X145.933 Y120.156 I-.62 J51.243 E.20798
; LINE_WIDTH: 1.03039
G1 F2471.956
G1 X144.624 Y120.174 E.27187
; LINE_WIDTH: 1.06348
G1 F2385.247
G1 X143.98 Y120.189 E.13866
; LINE_WIDTH: 1.09357
G1 F2311.491
G1 X143.327 Y120.204 E.14517
; LINE_WIDTH: 1.13364
G1 F2220.105
G1 X142.049 Y120.246 E.29566
; WIPE_START
G1 X143.327 Y120.204 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.131 Y120.456 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.241628
G1 F3000
M204 S6000
G1 X137.801 Y120.48 E.00918
; LINE_WIDTH: 0.287743
G1 X137.471 Y120.504 E.01267
; LINE_WIDTH: 0.334044
G1 X137.138 Y120.529 E.01629
; LINE_WIDTH: 0.38183
G1 X136.848 Y120.553 E.01733
; LINE_WIDTH: 0.43082
G1 X136.559 Y120.578 E.02057
; LINE_WIDTH: 0.479811
G1 X136.27 Y120.602 E.02382
; LINE_WIDTH: 0.529239
G1 X135.976 Y120.627 E.02757
; LINE_WIDTH: 0.575964
G1 X135.751 Y120.649 E.02349
; LINE_WIDTH: 0.619425
G1 X135.526 Y120.67 E.02573
; LINE_WIDTH: 0.662885
G1 X135.301 Y120.692 E.02797
; LINE_WIDTH: 0.706346
G1 X135.076 Y120.714 E.03021
; LINE_WIDTH: 0.750592
G1 X134.843 Y120.736 E.03366
; LINE_WIDTH: 0.795676
G1 X134.638 Y120.759 E.0319
; LINE_WIDTH: 0.840614
G1 X134.432 Y120.781 E.03402
; LINE_WIDTH: 0.885552
G1 F2939.735
G1 X134.226 Y120.804 E.03615
; LINE_WIDTH: 0.93049
G1 F2776.704
G1 X134.02 Y120.826 E.03827
; LINE_WIDTH: 0.972752
G1 F2639.064
G1 X133.815 Y120.849 E.04026
G1 X133.784 Y120.892 E.0103
; LINE_WIDTH: 0.917198
G1 F2823.011
G1 X133.438 Y121.387 E.1098
; WIPE_START
G1 X133.784 Y120.892 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.513 Y121.151 Z10.32 F42000
G1 Z9.92
G1 E.8 F1800
; LINE_WIDTH: 0.242407
G1 F3000
M204 S6000
G1 X131.348 Y121.177 E.00465
; LINE_WIDTH: 0.290071
G1 X131.183 Y121.202 E.00646
; LINE_WIDTH: 0.337736
G1 X131.019 Y121.227 E.00827
; LINE_WIDTH: 0.3854
G1 X130.854 Y121.253 E.01008
; LINE_WIDTH: 0.433949
G1 X130.683 Y121.279 E.01237
; LINE_WIDTH: 0.483021
G1 X130.543 Y121.303 E.01177
; LINE_WIDTH: 0.531298
G1 X130.403 Y121.327 E.01334
; LINE_WIDTH: 0.579574
G1 X130.263 Y121.352 E.0149
; LINE_WIDTH: 0.62785
G1 X130.123 Y121.376 E.01647
; LINE_WIDTH: 0.676126
G1 X129.983 Y121.4 E.01803
; LINE_WIDTH: 0.724403
G1 X129.843 Y121.424 E.0196
; LINE_WIDTH: 0.772679
G1 X129.703 Y121.448 E.02116
; LINE_WIDTH: 0.799324
G1 X129.689 Y121.451 E.00215
; LINE_WIDTH: 0.822099
G1 X129.397 Y121.507 E.04768
; LINE_WIDTH: 0.862671
G1 X129.104 Y121.563 E.05043
M204 S10000
G1 X112.209 Y134.52 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.421 Y132.383 I6.375 J-7.147 E.44653
G1 X122.193 Y120.612 E2.65807
G2 X119.602 Y119.602 I-4.781 J8.438 E.44551
G1 X128.069 Y128.069 E1.91193
G1 X128.069 Y127.931 E.02192
G1 X119.596 Y136.404 E1.91318
G2 X122.193 Y135.389 I-2.12 J-9.257 E.44679
G1 X110.421 Y123.617 E2.65824
G3 X112.211 Y121.482 I7.965 J4.856 E.44652
; CHANGE_LAYER
; Z_HEIGHT: 10.48
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.158 Y122.555 E-.57103
G1 X110.875 Y122.963 E-.18897
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 19/51
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z10.48 I-.899 J1.447 P1  F42000
G1 X128.996 Y134.227 Z10.48
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.328 Y134.872 E.38635
G1 X131.283 Y135.241 E.05937
G1 X124.745 Y135.241 E1.04398
G2 X122.776 Y135.741 I.031 J4.245 E.32763
G3 X118.037 Y118.815 I-4.957 J-7.739 E5.48075
G3 X122.775 Y120.258 I-.267 J9.372 E.80036
G2 X124.734 Y120.76 I2.042 J-3.898 E.32583
G1 X131.284 Y120.76 E1.04597
G1 X131.33 Y121.129 E.05934
G1 X128.845 Y121.816 E.41154
G1 X128.845 Y134.185 E1.97504
G1 X128.881 Y134.195 E.00583
M204 S10000
G1 X129.545 Y133.577 F42000
G1 F3215.099
M204 S6000
G1 X129.545 Y133.654 E.01231
G2 X139.255 Y135.478 I13.705 J-46.195 E1.58032
G1 X139.976 Y135.538 E.11557
G1 X139.96 Y135.94 E.06433
G1 X124.754 Y135.94 E2.42793
G2 X123.107 Y136.358 I.021 J3.541 E.274
G3 X118.059 Y118.115 I-5.291 J-8.356 E5.89136
G3 X123.106 Y119.642 I-.287 J10.055 E.85194
G2 X124.747 Y120.06 I1.701 J-3.248 E.27285
G1 X139.968 Y120.06 E2.43029
G1 X139.984 Y120.462 E.06428
G2 X131.255 Y121.868 I3.864 J51.791 E1.41349
G1 X129.545 Y122.347 E.28356
G1 X129.545 Y133.457 E1.77401
M204 S250
G1 X130.245 Y133.123 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X137.031 Y134.526 I12.474 J-43.218 E1.10749
G2 X148.754 Y134.982 I8.483 J-67.216 E1.87571
G3 X146.787 Y136.64 I-1.972 J-.344 E.44623
G1 X124.763 Y136.64 E3.51656
G2 X123.438 Y136.975 I.012 J2.837 E.22036
G3 X118.081 Y117.416 I-5.623 J-8.973 E6.30074
G3 X123.438 Y119.025 I-.307 J10.739 E.90352
G2 X124.761 Y119.36 I1.361 J-2.598 E.21988
G1 X146.787 Y119.36 E3.51695
G3 X148.753 Y121.018 I-.009 J2.006 E.44586
G2 X134.524 Y121.865 I-3.323 J64.127 E2.28079
G2 X130.245 Y122.878 I7.194 J39.945 E.70247
G1 X130.245 Y123.567 E.11007
G1 X130.245 Y132.434 E1.41576
G1 X130.245 Y133.003 E.09091
; WIPE_START
M204 S6000
G1 X131.455 Y133.461 E-.49165
G1 X132.141 Y133.631 E-.26835
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


G1 X132.124 Y135.156 F42000
G1 Z10.48
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.993852
G1 F2575.329
M204 S6000
G1 X131.653 Y135.098 E.09443
M204 S10000
G1 X132.124 Y135.156 F42000
; LINE_WIDTH: 0.964604
G1 F2664.528
M204 S6000
G1 X132.354 Y135.181 E.04457
; LINE_WIDTH: 0.916126
G1 F2826.816
G1 X132.572 Y135.204 E.03986
; LINE_WIDTH: 0.868929
G1 F3000
G1 X132.79 Y135.228 E.03749
; LINE_WIDTH: 0.821732
G1 X133.008 Y135.252 E.03513
; LINE_WIDTH: 0.774535
G1 X133.226 Y135.275 E.03277
; LINE_WIDTH: 0.72898
G1 X133.455 Y135.297 E.03193
; LINE_WIDTH: 0.685994
G1 X133.676 Y135.318 E.02866
; LINE_WIDTH: 0.643761
G1 X133.897 Y135.339 E.02652
; LINE_WIDTH: 0.601527
G1 X134.118 Y135.36 E.02438
; LINE_WIDTH: 0.559294
G1 X134.339 Y135.382 E.02224
; LINE_WIDTH: 0.514502
G1 X134.621 Y135.405 E.02541
; LINE_WIDTH: 0.467663
G1 X134.897 Y135.428 E.02201
; LINE_WIDTH: 0.421228
G1 X135.174 Y135.452 E.01907
; LINE_WIDTH: 0.374794
G1 X135.45 Y135.475 E.01613
; LINE_WIDTH: 0.329272
G1 X135.773 Y135.498 E.01545
; LINE_WIDTH: 0.284958
G1 X136.094 Y135.522 E.01208
; LINE_WIDTH: 0.240824
G1 X136.414 Y135.545 E.00884
; WIPE_START
G1 X136.094 Y135.522 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.318 Y135.754 Z10.88 F42000
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 1.13585
G1 F2215.284
M204 S6000
G1 X141.53 Y135.794 E.28105
; LINE_WIDTH: 1.09676
G1 F2303.953
G1 X142.162 Y135.81 E.1408
; LINE_WIDTH: 1.05692
G1 F2401.941
G1 X143.346 Y135.834 E.25327
; LINE_WIDTH: 1.02077
G1 F2498.348
G1 X144.465 Y135.846 E.22977
; LINE_WIDTH: 1.00423
M73 P60 R7
G1 F2545.082
G1 X146.777 Y135.844 E.46637
G2 X147.153 Y135.812 I-.034 J-2.607 E.07635
; LINE_WIDTH: 0.943374
G1 F2733.247
G2 X147.295 Y135.784 I-.41 J-2.466 E.0272
; LINE_WIDTH: 0.908731
G1 F2853.324
G1 X148.138 Y135.585 E.1558
; WIPE_START
G1 X147.295 Y135.784 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.713 Y128.163 Z10.88 F42000
G1 X148.138 Y120.414 Z10.88
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 0.913967
G1 F2834.502
M204 S6000
G2 X147.203 Y120.196 I-4.379 J16.67 E.17386
; LINE_WIDTH: 0.967907
G1 F2654.146
G1 X147.199 Y120.195 E.00076
G2 X147.072 Y120.176 I-.401 J2.197 E.02485
; LINE_WIDTH: 1.00554
G1 F2541.333
G2 X144.235 Y120.156 I-1.889 J66.531 E.57323
; LINE_WIDTH: 1.02967
G1 F2473.904
G1 X142.929 Y120.174 E.27102
; LINE_WIDTH: 1.06229
G1 F2388.247
G1 X142.286 Y120.189 E.13812
; LINE_WIDTH: 1.09203
G1 F2315.175
G1 X141.634 Y120.204 E.14463
; LINE_WIDTH: 1.12007
G1 F2250.247
G1 X140.98 Y120.225 E.14935
; LINE_WIDTH: 1.14599
G1 F2193.374
G1 X140.326 Y120.247 E.15323
; WIPE_START
G1 X140.98 Y120.225 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.409 Y120.456 Z10.88 F42000
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 0.240522
G1 F3000
M204 S6000
G1 X136.092 Y120.479 E.00873
; LINE_WIDTH: 0.284424
G1 X135.775 Y120.502 E.01191
; LINE_WIDTH: 0.328505
G1 X135.456 Y120.525 E.01523
; LINE_WIDTH: 0.375
G1 X135.167 Y120.55 E.01685
; LINE_WIDTH: 0.423662
G1 X134.878 Y120.574 E.02007
; LINE_WIDTH: 0.472324
G1 X134.59 Y120.598 E.02328
; LINE_WIDTH: 0.52141
G1 X134.296 Y120.623 E.02699
; LINE_WIDTH: 0.56782
G1 X134.071 Y120.645 E.02305
; LINE_WIDTH: 0.611015
G1 X133.847 Y120.666 E.02527
; LINE_WIDTH: 0.65421
G1 X133.622 Y120.688 E.0275
; LINE_WIDTH: 0.697405
G1 X133.397 Y120.709 E.02972
; LINE_WIDTH: 0.741372
G1 X133.165 Y120.732 E.03312
; LINE_WIDTH: 0.787213
G1 X132.95 Y120.755 E.03291
; LINE_WIDTH: 0.833961
G1 X132.735 Y120.779 E.03521
; LINE_WIDTH: 0.880708
G1 F2958.459
G1 X132.52 Y120.802 E.03752
; LINE_WIDTH: 0.927456
G1 F2787.142
G1 X132.305 Y120.825 E.03983
; LINE_WIDTH: 0.981698
G1 F2611.661
G1 X132.09 Y120.849 E.0425
G1 X131.714 Y121.387 E.12908
; WIPE_START
G1 X132.09 Y120.849 E-.57174
G1 X132.305 Y120.825 E-.18826
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.761 Y121.152 Z10.88 F42000
G1 Z10.48
G1 E.8 F1800
; LINE_WIDTH: 0.242068
G1 F3000
M204 S6000
G1 X129.55 Y121.181 E.00592
; LINE_WIDTH: 0.289037
G1 X129.339 Y121.21 E.0082
; LINE_WIDTH: 0.336006
G1 X129.128 Y121.239 E.01048
; LINE_WIDTH: 0.382975
G1 X128.917 Y121.268 E.01276
; LINE_WIDTH: 0.429944
G1 X128.707 Y121.297 E.01504
; LINE_WIDTH: 0.476913
G1 X128.496 Y121.326 E.01732
M204 S10000
G1 X128.496 Y134.675 F42000
; LINE_WIDTH: 0.476465
G1 F3000
M204 S6000
G1 X128.706 Y134.704 E.0173
; LINE_WIDTH: 0.429576
G1 X128.917 Y134.733 E.01502
; LINE_WIDTH: 0.382687
G1 X129.128 Y134.762 E.01274
; LINE_WIDTH: 0.335799
G1 X129.339 Y134.79 E.01047
; LINE_WIDTH: 0.28891
G1 X129.55 Y134.819 E.00819
; LINE_WIDTH: 0.242021
G1 X129.76 Y134.848 E.00592
; WIPE_START
G1 X129.55 Y134.819 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X123.5 Y130.166 Z10.88 F42000
G1 X112.211 Y121.482 Z10.88
G1 Z10.48
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.421 Y123.617 I6.154 J6.974 E.44652
G1 X122.193 Y135.389 E2.65821
G3 X119.601 Y136.399 I-4.643 J-8.083 E.44593
G1 X128.251 Y127.749 E1.95327
G1 X128.251 Y128.251 E.08003
G1 X119.602 Y119.602 E1.95296
G3 X122.192 Y120.612 I-2.191 J9.45 E.44546
G1 X110.419 Y132.385 E2.65859
G2 X112.209 Y134.521 I7.498 J-4.467 E.44689
; CHANGE_LAYER
; Z_HEIGHT: 11.04
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.19 Y133.485 E-.5521
G1 X110.876 Y133.037 E-.2079
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 20/51
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z11.04 I-.15 J1.697 P1  F42000
G1 X129.027 Y134.641 Z11.04
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.027 Y134.768 E.0204
G1 X129.473 Y134.866 E.0728
G1 X129.432 Y135.241 E.06018
G1 X124.745 Y135.241 E.74838
G2 X122.776 Y135.742 I.031 J4.246 E.32771
G3 X118.046 Y118.815 I-4.958 J-7.739 E5.48315
G3 X122.774 Y120.258 I-.276 J9.371 E.79877
G2 X124.734 Y120.76 I2.041 J-3.896 E.32585
G1 X129.433 Y120.76 E.75037
G1 X129.473 Y121.135 E.06018
G1 X129.027 Y121.232 E.07291
G1 X129.027 Y134.521 E2.12182
M204 S10000
G1 X129.727 Y134.141 F42000
G1 F3215.099
M204 S6000
G1 X129.727 Y134.205 E.0102
G2 X138.254 Y135.538 I12.891 J-54.534 E1.37939
G1 X138.237 Y135.94 E.06433
G1 X124.754 Y135.94 E2.15288
G2 X123.107 Y136.358 I.021 J3.541 E.27405
G3 X118.068 Y118.116 I-5.293 J-8.355 E5.89414
G3 X123.106 Y119.642 I-.296 J10.054 E.85039
G2 X124.747 Y120.06 I1.701 J-3.246 E.27288
G1 X138.244 Y120.06 E2.1551
G1 X138.261 Y120.462 E.0643
G2 X129.727 Y121.795 I4.291 J55.451 E1.3805
G1 X129.727 Y134.021 E1.95219
M204 S250
G1 X130.427 Y133.642 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X140.422 Y134.979 I12.486 J-55.338 E1.61233
G2 X147.84 Y134.939 I3.331 J-70.118 E1.18505
G1 X148.767 Y134.88 E.14819
G1 X148.765 Y134.9 E.00324
G3 X146.787 Y136.64 I-1.973 J-.249 E.45975
G1 X124.763 Y136.64 E3.51658
G2 X123.438 Y136.975 I.012 J2.837 E.2204
G3 X118.091 Y117.416 I-5.625 J-8.972 E6.30364
G3 X123.438 Y119.025 I-.316 J10.738 E.90199
G2 X124.761 Y119.36 I1.361 J-2.597 E.21991
G1 X146.786 Y119.36 E3.51692
G3 X148.765 Y121.1 I0 J1.995 E.45949
G1 X148.768 Y121.123 E.00375
G1 X148.003 Y121.069 E.12249
G2 X132.842 Y121.857 I-4.208 J65.224 E2.42955
G2 X130.427 Y122.358 I8.819 J48.573 E.39393
G1 X130.427 Y122.911 E.08821
G1 X130.427 Y133.09 E1.6253
G1 X130.427 Y133.522 E.06904
; WIPE_START
M204 S6000
G1 X131.786 Y133.94 E-.54043
G1 X132.354 Y134.049 E-.21957
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


G1 X132.189 Y135.341 F42000
G1 Z11.04
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.598347
G1 F3000
M204 S6000
G1 X132.414 Y135.362 E.02461
; LINE_WIDTH: 0.5555
G1 X132.638 Y135.384 E.0224
; LINE_WIDTH: 0.509928
G1 X132.926 Y135.408 E.02571
; LINE_WIDTH: 0.462145
G1 X133.21 Y135.431 E.02218
; LINE_WIDTH: 0.414766
G1 X133.493 Y135.455 E.01911
; LINE_WIDTH: 0.367387
G1 X133.776 Y135.479 E.01603
; LINE_WIDTH: 0.322683
G1 X134.084 Y135.501 E.01427
; LINE_WIDTH: 0.280935
G1 X134.39 Y135.523 E.01123
; LINE_WIDTH: 0.239363
G1 X134.695 Y135.545 E.00833
M204 S10000
G1 X132.189 Y135.341 F42000
; LINE_WIDTH: 0.641193
G1 F3000
M204 S6000
G1 X131.965 Y135.319 E.02681
; LINE_WIDTH: 0.68404
G1 X131.74 Y135.298 E.02902
; LINE_WIDTH: 0.727649
G1 X131.508 Y135.276 E.03237
; LINE_WIDTH: 0.772637
G1 X131.223 Y135.245 E.0426
; LINE_WIDTH: 0.818036
G1 X130.939 Y135.214 E.04557
; LINE_WIDTH: 0.863434
G1 X130.654 Y135.183 E.04853
; LINE_WIDTH: 0.908834
G1 F2852.953
G1 X130.37 Y135.152 E.0515
; LINE_WIDTH: 0.954233
G1 F2697.662
G1 X130.085 Y135.122 E.05446
; LINE_WIDTH: 0.999632
G1 F2558.404
G1 X129.8 Y135.091 E.05743
; WIPE_START
G1 X130.085 Y135.122 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.696 Y135.688 Z11.44 F42000
G1 X138.595 Y135.754 Z11.44
G1 Z11.04
M73 P61 R7
G1 E.8 F1800
; LINE_WIDTH: 1.13445
G1 F2218.34
M204 S6000
G1 X139.855 Y135.795 E.29158
; LINE_WIDTH: 1.09679
G1 F2303.882
G1 X140.381 Y135.809 E.11733
; LINE_WIDTH: 1.05886
G1 F2396.977
G1 X141.587 Y135.833 E.2584
; LINE_WIDTH: 1.01605
G1 F2511.509
G1 X143.855 Y135.85 E.46359
G1 X146.395 Y135.826 E.51913
; LINE_WIDTH: 1.05992
G1 F2394.271
G2 X146.922 Y135.81 I-.514 J-25.466 E.11311
; LINE_WIDTH: 1.04515
G1 F2432.5
G2 X147.187 Y135.774 I-.23 J-2.689 E.05643
; LINE_WIDTH: 0.978481
G1 F2621.448
G2 X148.173 Y135.534 I-3.623 J-17.057 E.19872
; WIPE_START
G1 X147.187 Y135.774 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.676 Y128.157 Z11.44 F42000
G1 X148.17 Y120.465 Z11.44
G1 Z11.04
G1 E.8 F1800
; LINE_WIDTH: 0.983714
G1 F2605.562
M204 S6000
G2 X147.191 Y120.227 I-4.609 J16.858 E.19847
; LINE_WIDTH: 1.04416
G1 F2435.122
G2 X146.753 Y120.182 I-.494 J2.594 E.09294
G1 X145.454 Y120.16 E.27387
; LINE_WIDTH: 1.01397
G1 F2517.36
G1 X143.845 Y120.15 E.32813
G1 X141.233 Y120.173 E.53274
; LINE_WIDTH: 1.06112
G1 F2391.215
G1 X140.592 Y120.188 E.13764
; LINE_WIDTH: 1.09052
G1 F2318.772
G1 X139.941 Y120.203 E.14413
; LINE_WIDTH: 1.11888
G1 F2252.915
G1 X139.272 Y120.225 E.15269
; LINE_WIDTH: 1.14581
G1 F2193.762
G1 X138.602 Y120.247 E.1568
; WIPE_START
G1 X139.272 Y120.225 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.686 Y120.456 Z11.44 F42000
G1 Z11.04
G1 E.8 F1800
; LINE_WIDTH: 0.239393
G1 F3000
M204 S6000
G1 X134.383 Y120.478 E.00826
; LINE_WIDTH: 0.281035
G1 X134.08 Y120.5 E.01115
; LINE_WIDTH: 0.322847
G1 X133.775 Y120.522 E.01416
; LINE_WIDTH: 0.368063
G1 X133.486 Y120.546 E.01638
; LINE_WIDTH: 0.416433
G1 X133.198 Y120.57 E.01957
; LINE_WIDTH: 0.464803
G1 X132.909 Y120.594 E.02277
; LINE_WIDTH: 0.513583
G1 X132.616 Y120.619 E.02643
; LINE_WIDTH: 0.559698
G1 X132.392 Y120.64 E.02261
; LINE_WIDTH: 0.602622
G1 X132.167 Y120.662 E.02482
; LINE_WIDTH: 0.645546
G1 X131.943 Y120.683 E.02702
; LINE_WIDTH: 0.688471
G1 X131.718 Y120.705 E.02923
; LINE_WIDTH: 0.732155
G1 X131.486 Y120.727 E.03259
; LINE_WIDTH: 0.776788
G1 X131.205 Y120.758 E.04232
; LINE_WIDTH: 0.821411
G1 X130.924 Y120.788 E.04519
; LINE_WIDTH: 0.866035
G1 X130.644 Y120.818 E.04807
; LINE_WIDTH: 0.910658
G1 F2846.368
G1 X130.363 Y120.849 E.05094
; LINE_WIDTH: 0.955282
G1 F2694.273
G1 X130.082 Y120.879 E.05382
; LINE_WIDTH: 0.999905
G1 F2557.608
G1 X129.801 Y120.91 E.05669
; WIPE_START
G1 X130.082 Y120.879 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.015 Y125.51 Z11.44 F42000
G1 X112.209 Y134.521 Z11.44
G1 Z11.04
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.421 Y132.383 I6.416 J-7.183 E.44655
G1 X122.192 Y120.612 E2.6582
G2 X119.602 Y119.602 I-4.784 J8.449 E.44541
G1 X128.433 Y128.433 E1.994
G1 X128.433 Y127.567 E.13813
G1 X119.601 Y136.399 E1.99431
G2 X122.193 Y135.389 I-2.042 J-9.073 E.44589
G1 X110.422 Y123.618 E2.65818
G3 X112.21 Y121.481 I8.413 J5.226 E.44636
; CHANGE_LAYER
; Z_HEIGHT: 11.6
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57239
G1 X110.875 Y122.963 E-.18761
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 21/51
; update layer progress
M73 L21
M991 S0 P20 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z11.6 I-.941 J1.42 P1  F42000
G1 X129.209 Y135.115 Z11.6
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X129.209 Y135.241 E.02011
G1 X124.745 Y135.241 E.71278
G2 X122.775 Y135.742 I.031 J4.245 E.3278
G3 X118.057 Y118.815 I-4.959 J-7.738 E5.4854
G3 X122.774 Y120.258 I-.286 J9.37 E.79702
G2 X124.733 Y120.76 I2.041 J-3.895 E.32589
G1 X129.209 Y120.76 E.71471
G1 X129.209 Y134.995 E2.27295
M204 S10000
G1 X129.962 Y134.634 F42000
G1 F3215.099
M204 S6000
G1 X131.051 Y134.839 E.17693
G2 X136.531 Y135.538 I9.755 J-54.698 E.88248
G1 X136.514 Y135.94 E.06434
G1 X124.754 Y135.94 E1.87779
G2 X123.107 Y136.358 I.021 J3.54 E.27414
G3 X118.079 Y118.116 I-5.294 J-8.355 E5.89637
G3 X123.106 Y119.642 I-.306 J10.052 E.84863
G2 X124.747 Y120.06 I1.701 J-3.245 E.27291
G1 X136.52 Y120.06 E1.87981
G1 X136.536 Y120.462 E.06432
G2 X129.909 Y121.377 I4.48 J56.938 E1.06885
G1 X129.909 Y134.557 E2.10458
M204 S250
G1 X130.609 Y134.045 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X142.148 Y135.06 I11.221 J-61.467 E1.85232
G2 X146.163 Y134.937 I-1.369 J-110.183 E.64134
G1 X147.148 Y134.873 E.15761
G1 X147.746 Y134.822 E.0958
G1 X147.762 Y134.821 E.00256
G1 X148.359 Y134.771 E.0958
G1 X148.78 Y134.727 E.06748
G1 X148.779 Y134.764 E.00586
G1 X148.775 Y134.798 E.00554
G3 X146.787 Y136.64 I-1.984 J-.147 E.47616
G1 X124.763 Y136.64 E3.51654
G2 X123.438 Y136.975 I.012 J2.836 E.22046
G3 X118.101 Y117.416 I-5.626 J-8.972 E6.30595
G3 X123.438 Y119.025 I-.326 J10.737 E.90026
G2 X124.761 Y119.36 I1.361 J-2.595 E.21992
G1 X146.786 Y119.36 E3.51694
G3 X148.776 Y121.205 I-.002 J1.998 E.47625
G1 X148.779 Y121.238 E.0054
G1 X148.78 Y121.271 E.00522
G2 X148.15 Y121.213 I-1.748 J15.662 E.10107
G1 X148.109 Y121.21 E.00645
G1 X147.512 Y121.156 E.0958
G1 X146.913 Y121.114 E.09581
G1 X146.873 Y121.111 E.00646
G1 X146.274 Y121.068 E.09581
G2 X132.356 Y121.65 I-4.168 J67.074 E2.22842
G2 X130.609 Y121.955 I5.457 J36.368 E.28314
G1 X130.609 Y122.401 E.07122
G1 X130.609 Y133.599 E1.78796
G1 X130.609 Y133.925 E.05206
; WIPE_START
M204 S6000
G1 X132.339 Y134.348 E-.67675
G1 X132.556 Y134.379 E-.08325
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


G1 X132.431 Y135.507 F42000
G1 Z11.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.308652
G1 F3000
M204 S6000
G1 X132.16 Y135.487 E.01165
; LINE_WIDTH: 0.346843
G1 X131.919 Y135.467 E.01251
; LINE_WIDTH: 0.386856
G1 X131.678 Y135.447 E.01472
; LINE_WIDTH: 0.426869
G1 X131.437 Y135.427 E.01693
; LINE_WIDTH: 0.466881
G1 X131.196 Y135.407 E.01914
; LINE_WIDTH: 0.507296
G1 X130.95 Y135.387 E.0218
; LINE_WIDTH: 0.548358
G1 X130.672 Y135.36 E.0273
; LINE_WIDTH: 0.58952
G1 X130.394 Y135.334 E.02992
; LINE_WIDTH: 0.630681
G1 X130.116 Y135.308 E.03254
; LINE_WIDTH: 0.671843
G1 X129.838 Y135.281 E.03517
; LINE_WIDTH: 0.713005
G1 X129.559 Y135.255 E.03779
M204 S10000
G1 X132.431 Y135.507 F42000
; LINE_WIDTH: 0.272527
G1 F3000
M204 S6000
G1 X132.698 Y135.526 E.00933
; LINE_WIDTH: 0.23656
G1 X132.966 Y135.545 E.00713
; WIPE_START
G1 X132.698 Y135.526 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.872 Y135.753 Z12 F42000
M73 P62 R7
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 1.14683
G1 F2191.59
M204 S6000
G1 X137.525 Y135.775 E.15301
; LINE_WIDTH: 1.12087
G1 F2248.432
G1 X138.178 Y135.796 E.14914
; LINE_WIDTH: 1.09671
G1 F2304.062
G1 X138.606 Y135.808 E.0953
; LINE_WIDTH: 1.0607
G1 F2392.292
G1 X139.828 Y135.833 E.26233
; LINE_WIDTH: 1.01643
G1 F2510.441
G1 X142.153 Y135.85 E.47556
G1 X144.696 Y135.826 E.52002
; LINE_WIDTH: 1.06443
G1 F2382.826
G1 X145.332 Y135.811 E.137
; LINE_WIDTH: 1.09392
G1 F2310.683
G1 X145.959 Y135.796 E.13939
; LINE_WIDTH: 1.12194
G1 F2246.042
G1 X146.372 Y135.783 E.09442
; LINE_WIDTH: 1.14856
G1 F2187.908
G1 X146.776 Y135.77 E.09479
; LINE_WIDTH: 1.15276
G1 F2179.006
G2 X147.131 Y135.732 I-.202 J-3.589 E.08416
G1 X147.168 Y135.725 E.00888
; LINE_WIDTH: 1.08881
G1 F2322.872
G2 X148.224 Y135.446 I-3.522 J-15.51 E.24138
; WIPE_START
G1 X147.168 Y135.725 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.695 Y128.11 Z12 F42000
G1 X148.219 Y120.543 Z12
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 1.09473
G1 F2308.753
M204 S6000
G2 X147.173 Y120.278 I-5.067 J17.84 E.24001
; LINE_WIDTH: 1.14903
G1 F2186.901
G2 X146.301 Y120.214 I-.75 J4.27 E.20537
; LINE_WIDTH: 1.11198
G1 F2268.587
G1 X145.661 Y120.198 E.14501
; LINE_WIDTH: 1.07878
G1 F2347.169
G1 X145.011 Y120.181 E.14209
; LINE_WIDTH: 1.04092
G1 F2443.672
G1 X143.713 Y120.16 E.2728
; LINE_WIDTH: 1.01375
G1 F2517.981
G1 X142.145 Y120.15 E.3198
G1 X139.538 Y120.173 E.53152
; LINE_WIDTH: 1.05995
G1 F2394.203
G1 X138.898 Y120.187 E.13716
; LINE_WIDTH: 1.08899
G1 F2322.418
G1 X138.249 Y120.202 E.14363
; LINE_WIDTH: 1.11771
G1 F2255.572
G1 X137.563 Y120.224 E.15607
; LINE_WIDTH: 1.14562
G1 F2194.173
G1 X136.878 Y120.247 E.16044
; WIPE_START
G1 X137.563 Y120.224 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.962 Y120.456 Z12 F42000
G1 Z11.6
G1 E.8 F1800
; LINE_WIDTH: 0.236164
G1 F3000
M204 S6000
G1 X132.701 Y120.474 E.00692
; LINE_WIDTH: 0.271329
G1 X132.441 Y120.493 E.00901
; LINE_WIDTH: 0.306643
G1 X132.178 Y120.512 E.01121
; LINE_WIDTH: 0.344652
G1 X131.933 Y120.532 E.01257
; LINE_WIDTH: 0.385155
G1 X131.689 Y120.553 E.01484
; LINE_WIDTH: 0.425659
G1 X131.444 Y120.573 E.01711
; LINE_WIDTH: 0.466162
G1 X131.199 Y120.593 E.01937
; LINE_WIDTH: 0.507073
G1 X130.95 Y120.614 E.0221
; LINE_WIDTH: 0.548383
G1 X130.672 Y120.64 E.02729
; LINE_WIDTH: 0.589546
G1 X130.394 Y120.667 E.02992
; LINE_WIDTH: 0.630709
G1 X130.116 Y120.693 E.03254
; LINE_WIDTH: 0.671872
G1 X129.837 Y120.719 E.03516
; LINE_WIDTH: 0.713035
G1 X129.559 Y120.746 E.03779
; WIPE_START
G1 X129.837 Y120.719 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X122.212 Y121.049 Z12 F42000
G1 X112.21 Y121.481 Z12
G1 Z11.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.422 Y123.618 I6.636 J7.372 E.44635
G1 X122.193 Y135.389 E2.65815
G3 X119.601 Y136.399 I-4.626 J-8.044 E.44585
G1 X128.615 Y127.385 E2.03534
G1 X128.615 Y128.615 E.19624
G1 X119.602 Y119.602 E2.03504
G3 X122.192 Y120.612 I-2.196 J9.465 E.44536
G1 X110.421 Y132.383 E2.65827
G2 X112.209 Y134.521 I8.205 J-5.048 E.44655
; CHANGE_LAYER
; Z_HEIGHT: 12.16
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.196 Y133.491 E-.54874
G1 X110.877 Y133.036 E-.21126
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 22/51
; update layer progress
M73 L22
M991 S0 P21 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z12.16 I-.201 J1.692 P1  F42000
G1 X129.391 Y135.241 Z12.16
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.745 Y135.241 E.74183
G2 X122.775 Y135.742 I.031 J4.244 E.32786
G3 X118.066 Y118.816 I-4.96 J-7.738 E5.48736
G3 X122.773 Y120.258 I-.295 J9.368 E.79539
G2 X124.733 Y120.76 I2.042 J-3.893 E.32587
G1 X129.391 Y120.76 E.74388
G1 X129.391 Y135.121 E2.29305
M204 S10000
G1 X130.133 Y134.985 F42000
G1 F3215.099
M204 S6000
G1 X131.669 Y135.207 E.24783
G2 X134.808 Y135.538 I8.069 J-61.504 E.50408
G1 X134.792 Y135.94 E.06435
G1 X124.754 Y135.94 E1.60269
G2 X123.106 Y136.359 I.021 J3.54 E.27418
G3 X118.089 Y118.116 I-5.294 J-8.355 E5.89788
G3 X123.105 Y119.641 I-.315 J10.05 E.84705
G2 X124.747 Y120.06 I1.701 J-3.243 E.27292
G1 X134.795 Y120.06 E1.6045
G1 X134.812 Y120.463 E.06433
G2 X130.091 Y121.022 I4.885 J61.467 E.75922
G1 X130.091 Y134.901 E2.21624
; WIPE_START
G1 X131.669 Y135.207 E-.61072
G1 X132.059 Y135.255 E-.14928
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.268 Y129.676 Z12.56 F42000
G1 X145.874 Y120.461 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X145.892 Y120.06 E.0641
G3 X146.864 Y120.062 I.442 J17.398 E.15521
G3 X147.514 Y120.277 I-.101 J1.398 E.11047
G1 X147.41 Y120.606 E.05511
G2 X145.993 Y120.47 I-4.383 J38.202 E.22734
; WIPE_START
G1 X145.892 Y120.06 E-.16055
G1 X146.864 Y120.062 E-.36933
G1 X147.087 Y120.095 E-.08574
G1 X147.223 Y120.135 E-.05394
G1 X147.437 Y120.239 E-.09044
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.683 Y127.834 Z12.56 F42000
G1 X145.878 Y135.94 Z12.56
G1 Z12.16
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X145.861 Y135.538 E.06427
G2 X147.416 Y135.393 I-3.027 J-40.909 E.24933
G1 X147.518 Y135.723 E.05501
G3 X146.778 Y135.94 I-.742 J-1.155 E.12491
G1 X145.998 Y135.94 E.12441
; WIPE_START
G1 X145.861 Y135.538 E-.16144
G1 X147.416 Y135.393 E-.59332
G1 X147.42 Y135.407 E-.00524
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.802 Y134.933 Z12.56 F42000
G1 X130.791 Y134.373 Z12.56
G1 Z12.16
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X144.453 Y134.936 I9.579 J-66.362 E2.1872
G1 X145.148 Y134.892 E.11112
G1 X145.453 Y134.871 E.04878
G1 X146.05 Y134.82 E.0958
G1 X146.067 Y134.819 E.00266
G1 X146.665 Y134.768 E.0958
G1 X147.748 Y134.655 E.17381
G1 X148.782 Y134.528 E.16646
G1 X148.782 Y134.644 E.0185
G1 X148.782 Y134.645 E.00024
G3 X146.787 Y136.64 I-2 J-.005 E.50008
G1 X124.763 Y136.64 E3.51656
G2 X123.438 Y136.975 I.011 J2.836 E.22049
G3 X118.111 Y117.417 I-5.626 J-8.972 E6.30746
G3 X123.437 Y119.025 I-.335 J10.735 E.89872
G2 X124.761 Y119.36 I1.361 J-2.594 E.21995
G1 X146.786 Y119.36 E3.51696
G3 X148.782 Y121.353 I0 J1.996 E.50005
G1 X148.782 Y121.473 E.01927
G1 X148.222 Y121.4 E.09019
M73 P62 R6
G1 X147.607 Y121.332 E.0988
G1 X147.011 Y121.266 E.09581
G1 X146.413 Y121.212 E.0958
G1 X146.371 Y121.209 E.00672
G1 X145.774 Y121.155 E.0958
G1 X145.175 Y121.113 E.09581
M73 P63 R6
G1 X145.144 Y121.11 E.00491
G1 X144.546 Y121.068 E.09581
G2 X130.791 Y121.627 I-4.18 J66.623 E2.20204
G1 X130.791 Y122.003 E.05997
G1 X130.791 Y133.997 E1.9152
G1 X130.791 Y134.253 E.04083
; WIPE_START
M204 S6000
G1 X132.757 Y134.622 E-.76
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


G1 X131.241 Y135.545 F42000
G1 Z12.16
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242041
G1 F3000
M204 S6000
G1 X130.866 Y135.518 E.01045
; LINE_WIDTH: 0.288969
G1 X130.491 Y135.491 E.01448
; LINE_WIDTH: 0.335898
G1 X130.116 Y135.464 E.0185
; LINE_WIDTH: 0.382826
G1 X129.741 Y135.437 E.02253
; WIPE_START
G1 X130.116 Y135.464 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.15 Y135.755 Z12.56 F42000
G1 Z12.16
G1 E.8 F1800
; LINE_WIDTH: 1.1449
G1 F2195.712
M204 S6000
G1 X135.827 Y135.776 E.15838
; LINE_WIDTH: 1.11838
G1 F2254.054
G1 X136.504 Y135.798 E.15428
; LINE_WIDTH: 1.08274
G1 F2337.497
G1 X137.447 Y135.819 E.2072
; LINE_WIDTH: 1.0498
G1 F2420.339
G1 X138.069 Y135.832 E.13195
; LINE_WIDTH: 1.01141
G1 F2524.6
G1 X141.724 Y135.843 E.74336
; LINE_WIDTH: 1.03234
G1 F2466.677
G1 X142.998 Y135.825 E.26518
; LINE_WIDTH: 1.06552
G1 F2380.076
G1 X143.634 Y135.81 E.13715
; LINE_WIDTH: 1.09524
G1 F2307.544
G1 X144.261 Y135.795 E.13956
; LINE_WIDTH: 1.13435
G1 F2218.565
G1 X145.52 Y135.754 E.2915
; WIPE_START
G1 X144.261 Y135.795 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.883 Y128.188 Z12.56 F42000
G1 X145.533 Y120.248 Z12.56
G1 Z12.16
G1 E.8 F1800
; LINE_WIDTH: 1.14346
G1 F2198.806
M204 S6000
G1 X144.561 Y120.214 E.22697
; LINE_WIDTH: 1.11104
G1 F2270.754
G1 X143.92 Y120.197 E.14501
; LINE_WIDTH: 1.07797
G1 F2349.147
G1 X143.27 Y120.181 E.1421
; LINE_WIDTH: 1.04031
G1 F2445.295
G1 X141.969 Y120.16 E.27325
; LINE_WIDTH: 1.01352
G1 F2518.64
G1 X140.443 Y120.15 E.31102
G1 X137.842 Y120.172 E.53013
; LINE_WIDTH: 1.05875
G1 F2397.261
G1 X137.204 Y120.187 E.13668
; LINE_WIDTH: 1.08745
G1 F2326.118
G1 X136.557 Y120.201 E.14289
; LINE_WIDTH: 1.11603
G1 F2259.376
G1 X135.855 Y120.223 E.15954
; LINE_WIDTH: 1.1441
G1 F2197.43
G1 X135.153 Y120.246 E.16403
; WIPE_START
G1 X135.855 Y120.223 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.24 Y120.456 Z12.56 F42000
G1 Z12.16
G1 E.8 F1800
; LINE_WIDTH: 0.242092
G1 F3000
M204 S6000
G1 X130.866 Y120.483 E.01045
; LINE_WIDTH: 0.289111
G1 X130.491 Y120.51 E.01448
; LINE_WIDTH: 0.336129
G1 X130.116 Y120.537 E.01851
; LINE_WIDTH: 0.383148
G1 X129.741 Y120.564 E.02254
; WIPE_START
G1 X130.116 Y120.537 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.101 Y125.234 Z12.56 F42000
G1 X112.209 Y134.521 Z12.56
G1 Z12.16
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.42 Y132.384 I6.413 J-7.186 E.44656
G1 X122.192 Y120.612 E2.65834
G2 X119.603 Y119.603 I-4.79 J8.467 E.44531
G1 X128.796 Y128.796 E2.07609
G1 X128.796 Y127.204 E.25435
G1 X119.601 Y136.399 E2.07637
G2 X122.193 Y135.389 I-2.025 J-9.031 E.44581
G1 X110.422 Y123.618 E2.65813
G3 X112.21 Y121.481 I8.437 J5.245 E.44634
; CHANGE_LAYER
; Z_HEIGHT: 12.72
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57241
G1 X110.875 Y122.963 E-.18759
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 23/51
; update layer progress
M73 L23
M991 S0 P22 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z12.72 I-.935 J1.424 P1  F42000
G1 X129.573 Y135.241 Z12.72
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.745 Y135.241 E.77087
G2 X122.774 Y135.742 I.031 J4.244 E.32797
G3 X118.077 Y118.816 I-4.96 J-7.738 E5.48949
G3 X122.773 Y120.257 I-.306 J9.366 E.79365
G2 X124.732 Y120.76 I2.042 J-3.891 E.32593
G1 X129.573 Y120.76 E.77296
G1 X129.573 Y135.121 E2.29305
M204 S10000
G1 X130.309 Y135.269 F42000
G1 F3215.099
M204 S6000
G1 X133.085 Y135.538 E.44545
G1 X133.069 Y135.94 E.06436
G1 X124.754 Y135.94 E1.3276
G2 X123.106 Y136.359 I.021 J3.54 E.27426
G3 X118.099 Y118.117 I-5.294 J-8.355 E5.89953
G3 X123.105 Y119.641 I-.326 J10.049 E.8453
G2 X124.746 Y120.06 I1.701 J-3.242 E.27297
G1 X133.07 Y120.06 E1.32907
G1 X133.087 Y120.463 E.06435
G2 X130.273 Y120.735 I5.558 J72.032 E.45138
G1 X130.273 Y135.181 E2.30661
; WIPE_START
G1 X132.257 Y135.433 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.004 Y129.456 Z13.12 F42000
G1 X144.149 Y120.461 Z13.12
G1 Z12.72
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X144.167 Y120.06 E.06411
G1 X146.863 Y120.062 E.43055
G3 X147.73 Y120.465 I-.074 J1.295 E.15633
G1 X148.124 Y120.908 E.0946
G2 X144.269 Y120.471 I-9.891 J70.144 E.61968
; WIPE_START
G1 X144.167 Y120.06 E-.16095
G1 X145.743 Y120.061 E-.59905
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.984 Y127.656 Z13.12 F42000
G1 X144.155 Y135.94 Z13.12
G1 Z12.72
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X144.138 Y135.538 E.06425
G2 X148.112 Y135.087 I-4.207 J-54.705 E.63877
G1 X147.741 Y135.523 E.09147
G3 X146.778 Y135.94 I-.961 J-.899 E.17235
G1 X144.275 Y135.94 E.39971
; WIPE_START
G1 X144.138 Y135.538 E-.16141
G1 X145.706 Y135.387 E-.59859
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.083 Y134.997 Z13.12 F42000
G1 X130.973 Y134.633 Z13.12
G1 Z12.72
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X142.732 Y134.936 I7.656 J-68.735 E1.88051
G1 X143.756 Y134.869 E.16392
G1 X144.354 Y134.818 E.09581
G1 X144.373 Y134.816 E.003
G1 X144.971 Y134.765 E.09581
G1 X146.162 Y134.64 E.19131
G1 X147.327 Y134.494 E.18744
G1 X148.461 Y134.328 E.18302
G1 X148.782 Y134.274 E.05201
G1 X148.782 Y134.446 E.02757
G3 X146.787 Y136.64 I-1.999 J.186 E.53277
G1 X124.763 Y136.64 E3.51658
G2 X123.438 Y136.975 I.011 J2.836 E.22055
G3 X118.121 Y117.417 I-5.626 J-8.972 E6.30915
G3 X123.437 Y119.025 I-.346 J10.734 E.89698
G2 X124.761 Y119.36 I1.361 J-2.593 E.21999
G1 X146.786 Y119.36 E3.51698
G3 X148.782 Y121.555 I-.008 J2.013 E.53261
G1 X148.782 Y121.725 E.02704
G1 X147.671 Y121.554 E.17946
G1 X146.487 Y121.398 E.19067
G1 X145.891 Y121.333 E.0958
G1 X145.274 Y121.265 E.0991
G1 X144.677 Y121.211 E.0958
G1 X144.633 Y121.207 E.007
G1 X144.035 Y121.154 E.0958
G1 X143.437 Y121.112 E.09581
M73 P64 R6
G1 X143.403 Y121.109 E.00549
G1 X142.804 Y121.067 E.09581
G2 X130.973 Y121.367 I-4.176 J68.698 E1.89207
G1 X130.973 Y121.683 E.05039
G1 X130.973 Y134.318 E2.01742
G1 X130.973 Y134.513 E.03122
; WIPE_START
M204 S6000
G1 X132.452 Y134.784 E-.57141
G1 X132.947 Y134.824 E-.18859
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


G1 X133.427 Y135.755 F42000
G1 Z12.72
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.14406
G1 F2197.517
M204 S6000
G1 X134.129 Y135.777 E.16406
; LINE_WIDTH: 1.11618
G1 F2259.034
G1 X134.831 Y135.799 E.1596
; LINE_WIDTH: 1.08601
G1 F2329.601
G1 X135.575 Y135.815 E.16417
; LINE_WIDTH: 1.05396
G1 F2409.561
G1 X136.311 Y135.831 E.15666
; LINE_WIDTH: 1.01174
G1 F2523.663
G1 X140.024 Y135.843 E.75545
; LINE_WIDTH: 1.03305
G1 F2464.75
G1 X141.3 Y135.825 E.26573
; LINE_WIDTH: 1.06665
G1 F2377.257
G1 X141.937 Y135.81 E.13756
; LINE_WIDTH: 1.09665
G1 F2304.202
G1 X142.565 Y135.795 E.14002
; LINE_WIDTH: 1.13513
G1 F2216.849
G1 X143.797 Y135.754 E.28537
; WIPE_START
G1 X142.565 Y135.795 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.173 Y128.186 Z13.12 F42000
G1 X143.808 Y120.248 Z13.12
G1 Z12.72
G1 E.8 F1800
; LINE_WIDTH: 1.14297
G1 F2199.868
M204 S6000
G1 X142.822 Y120.213 E.23039
; LINE_WIDTH: 1.11012
G1 F2272.854
G1 X142.179 Y120.197 E.14525
; LINE_WIDTH: 1.07713
G1 F2351.204
G1 X141.527 Y120.18 E.14234
; LINE_WIDTH: 1.03963
G1 F2447.115
G1 X140.222 Y120.159 E.27386
; LINE_WIDTH: 1.01369
G1 F2518.14
G1 X138.742 Y120.15 E.30173
G1 X136.146 Y120.172 E.52913
; LINE_WIDTH: 1.05759
G1 F2400.227
G1 X135.51 Y120.186 E.1362
; LINE_WIDTH: 1.08593
G1 F2329.786
G1 X134.864 Y120.2 E.14234
; LINE_WIDTH: 1.11473
G1 F2262.32
G1 X134.146 Y120.223 E.16302
; LINE_WIDTH: 1.1436
G1 F2198.501
G1 X133.428 Y120.245 E.16775
; WIPE_START
G1 X134.146 Y120.223 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.526 Y120.66 Z13.12 F42000
G1 X112.21 Y121.482 Z13.12
G1 Z12.72
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.422 Y123.618 I6.655 J7.387 E.44634
G1 X122.193 Y135.389 E2.6581
G3 X119.602 Y136.398 I-4.609 J-8.004 E.44578
G1 X128.978 Y127.022 E2.11742
G1 X128.978 Y128.978 E.31246
G1 X119.603 Y119.603 E2.11713
G3 X122.192 Y120.612 I-2.203 J9.483 E.44527
G1 X110.42 Y132.384 E2.6584
G2 X112.209 Y134.521 I8.201 J-5.049 E.44657
; CHANGE_LAYER
; Z_HEIGHT: 13.28
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.201 Y133.497 E-.54591
G1 X110.877 Y133.036 E-.21409
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 24/51
; update layer progress
M73 L24
M991 S0 P23 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z13.28 I-.198 J1.692 P1  F42000
G1 X129.755 Y135.241 Z13.28
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.746 Y135.241 E.79992
G2 X122.774 Y135.743 I.03 J4.243 E.32806
G3 X118.086 Y118.816 I-4.96 J-7.738 E5.4911
G3 X122.772 Y120.257 I-.315 J9.364 E.79201
G2 X124.732 Y120.76 I2.042 J-3.891 E.32593
G1 X129.755 Y120.76 E.80213
G1 X129.755 Y135.121 E2.29305
M204 S10000
G1 X130.478 Y135.466 F42000
G1 F3215.099
M204 S6000
G1 X131.36 Y135.538 E.1413
G1 X131.344 Y135.94 E.06438
G1 X124.755 Y135.94 E1.05217
G2 X123.106 Y136.359 I.021 J3.539 E.27432
G3 X118.109 Y118.117 I-5.294 J-8.355 E5.90103
G3 X123.105 Y119.641 I-.335 J10.047 E.84371
G2 X124.746 Y120.06 I1.702 J-3.242 E.273
G1 X131.343 Y120.06 E1.05338
G1 X131.359 Y120.463 E.06439
G1 X130.455 Y120.536 E.14488
G1 X130.455 Y135.367 E2.36819
; WIPE_START
G1 X131.36 Y135.538 E-.35002
G1 X131.344 Y135.94 E-.15322
G1 X130.668 Y135.94 E-.25676
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.285 Y129.862 Z13.68 F42000
G1 X142.425 Y120.461 Z13.68
G1 Z13.28
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X142.442 Y120.06 E.06411
G1 X146.863 Y120.062 E.70588
G3 X147.961 Y120.806 I-.071 J1.287 E.22241
G1 X148.125 Y121.202 E.06835
G2 X142.544 Y120.471 I-10.337 J57.265 E.89906
; WIPE_START
G1 X142.442 Y120.06 E-.16082
G1 X144.019 Y120.061 E-.59918
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.26 Y127.655 Z13.68 F42000
G1 X142.432 Y135.94 Z13.68
G1 Z13.28
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X142.414 Y135.538 E.06424
G2 X148.12 Y134.804 I-4.746 J-59.403 E.91886
G1 X147.978 Y135.159 E.06101
G3 X146.778 Y135.94 I-1.187 J-.511 E.24225
G1 X142.552 Y135.94 E.67487
; WIPE_START
G1 X142.414 Y135.538 E-.16139
G1 X143.343 Y135.459 E-.35403
G1 X143.982 Y135.386 E-.24458
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.357 Y135.049 Z13.68 F42000
G1 X131.155 Y134.819 Z13.68
G1 Z13.28
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X141.017 Y134.936 I5.752 J-69.12 E1.57611
G1 X142.06 Y134.866 E.16706
G1 X142.658 Y134.815 E.0958
G1 X142.678 Y134.814 E.00322
G1 X143.276 Y134.762 E.0958
G1 X144.469 Y134.637 E.19148
G1 X145.354 Y134.526 E.14251
G1 X145.636 Y134.49 E.04526
G1 X146.77 Y134.323 E.18303
G1 X147.769 Y134.154 E.16181
G1 F2850
G1 X148.782 Y133.959 E.16479
G1 F3215.099
G1 X148.782 Y134.192 E.03711
G3 X148.691 Y135.244 I-3.026 J.269 E.16949
G3 X146.787 Y136.64 I-1.905 J-.601 E.40347
G1 X124.763 Y136.64 E3.5166
G2 X123.437 Y136.975 I.011 J2.836 E.22058
G3 X118.131 Y117.417 I-5.626 J-8.972 E6.31066
G3 X123.437 Y119.025 I-.355 J10.732 E.89543
G2 X124.76 Y119.36 I1.361 J-2.592 E.22003
G1 X146.786 Y119.36 E3.517
G3 X148.782 Y121.357 I.004 J1.992 E.50094
G1 X148.782 Y121.806 E.07183
M73 P65 R6
G1 X148.782 Y122.043 E.03779
G1 F2700
G1 X148.206 Y121.927 E.09389
G1 F3000
G1 X147.091 Y121.729 E.18084
G1 F3215.099
G1 X145.939 Y121.553 E.1861
G1 X145.063 Y121.437 E.14105
G1 X144.753 Y121.397 E.04996
G1 X144.156 Y121.332 E.09581
G1 X143.538 Y121.264 E.09933
G1 X142.94 Y121.21 E.0958
G1 X142.895 Y121.206 E.00729
G1 X142.297 Y121.152 E.0958
G1 X141.699 Y121.111 E.09581
G1 X141.687 Y121.11 E.0019
G1 X141.088 Y121.068 E.09581
G2 X131.155 Y121.182 I-4.17 J69.598 E1.58755
G1 X131.155 Y121.43 E.03971
G1 X131.155 Y134.57 E2.09811
G1 X131.155 Y134.699 E.02053
; WIPE_START
M204 S6000
G1 X133.139 Y134.947 E-.76
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


G1 X133.251 Y135.803 F42000
G1 Z13.28
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.11043
G1 F2272.147
M204 S6000
G1 X132.476 Y135.779 E.1751
; LINE_WIDTH: 1.14218
G1 F2201.568
G1 X131.702 Y135.755 E.18071
M204 S10000
G1 X133.251 Y135.803 F42000
; LINE_WIDTH: 1.08054
G1 F2342.874
M204 S6000
G1 X133.905 Y135.817 E.14342
; LINE_WIDTH: 1.0529
G1 F2412.299
G1 X134.55 Y135.831 E.13732
; LINE_WIDTH: 1.01208
G1 F2522.686
G1 X138.324 Y135.843 E.76794
; LINE_WIDTH: 1.03375
G1 F2462.853
G1 X139.601 Y135.824 E.26629
; LINE_WIDTH: 1.06774
G1 F2374.506
G1 X140.239 Y135.809 E.13789
; LINE_WIDTH: 1.09803
G1 F2300.951
G1 X140.868 Y135.794 E.14039
; LINE_WIDTH: 1.13593
G1 F2215.111
G1 X142.073 Y135.754 E.27946
; WIPE_START
G1 X140.868 Y135.794 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.989 Y135.545 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 0.23645
G1 F3000
M204 S6000
G1 X146.25 Y135.526 E.00693
; LINE_WIDTH: 0.272213
G1 X146.511 Y135.507 E.00906
; LINE_WIDTH: 0.307976
G1 X146.771 Y135.488 E.0112
; LINE_WIDTH: 0.327664
G2 X147.16 Y135.414 I-.094 J-1.565 E.01877
; LINE_WIDTH: 0.285793
G1 X147.407 Y135.327 E.0099
; WIPE_START
G1 X147.16 Y135.414 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.284 Y127.783 Z13.68 F42000
G1 X147.399 Y120.68 Z13.68
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 0.236083
G1 F3000
M204 S6000
G2 X147.272 Y120.625 I-.675 J1.385 E.00366
; LINE_WIDTH: 0.264982
G1 X147.243 Y120.614 E.00103
; LINE_WIDTH: 0.292811
G1 X147.12 Y120.574 E.00511
; LINE_WIDTH: 0.332144
G2 X146.838 Y120.52 I-.535 J2.029 E.01387
; LINE_WIDTH: 0.316795
G1 X146.56 Y120.499 E.01253
; LINE_WIDTH: 0.277851
G1 X146.281 Y120.477 E.01005
; LINE_WIDTH: 0.238907
G1 X146.003 Y120.456 E.00757
; WIPE_START
G1 X146.281 Y120.477 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.084 Y120.248 Z13.68 F42000
G1 Z13.28
G1 E.8 F1800
; LINE_WIDTH: 1.14245
G1 F2200.97
M204 S6000
G1 X141.081 Y120.213 E.23394
; LINE_WIDTH: 1.10917
G1 F2275.04
G1 X140.438 Y120.196 E.14529
; LINE_WIDTH: 1.07631
G1 F2353.227
G1 X139.785 Y120.18 E.14239
; LINE_WIDTH: 1.03903
G1 F2448.715
G1 X138.479 Y120.159 E.27397
; LINE_WIDTH: 1.01337
G1 F2519.056
G1 X137.04 Y120.15 E.29313
G1 X134.451 Y120.171 E.52764
; LINE_WIDTH: 1.06743
G1 F2375.289
G1 X133.301 Y120.196 E.24854
; LINE_WIDTH: 1.09259
G1 F2313.822
G1 X133.293 Y120.196 E.0019
; LINE_WIDTH: 1.10917
G1 F2275.048
G1 X132.497 Y120.221 E.17971
; LINE_WIDTH: 1.14189
G1 F2202.176
G1 X131.701 Y120.245 E.18565
; WIPE_START
G1 X132.497 Y120.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.258 Y124.618 Z13.68 F42000
G1 X112.209 Y134.521 Z13.68
G1 Z13.28
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.42 Y132.385 I6.409 J-7.187 E.44657
G1 X122.192 Y120.612 E2.65848
G2 X119.603 Y119.603 I-4.796 J8.484 E.44523
G1 X129.16 Y129.16 E2.15819
G1 X129.16 Y126.84 E.37056
G1 X119.602 Y136.398 E2.15845
G2 X122.193 Y135.389 I-2.01 J-8.994 E.44573
G1 X110.422 Y123.618 E2.65807
G3 X112.21 Y121.482 I8.456 J5.26 E.44633
; CHANGE_LAYER
; Z_HEIGHT: 13.84
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.558 E-.57246
G1 X110.875 Y122.963 E-.18754
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 25/51
; update layer progress
M73 L25
M991 S0 P24 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z13.84 I-.923 J1.432 P1  F42000
G1 X129.937 Y135.241 Z13.84
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.746 Y135.241 E.82897
G2 X122.774 Y135.743 I.03 J4.243 E.3281
G3 X118.097 Y118.817 I-4.96 J-7.739 E5.49276
G3 X122.772 Y120.257 I-.325 J9.363 E.79025
G2 X124.732 Y120.76 I2.042 J-3.888 E.32597
G1 X129.937 Y120.76 E.83121
G1 X129.937 Y135.121 E2.29305
M204 S10000
G1 X130.637 Y135.613 F42000
G1 F3215.099
M204 S6000
G1 X130.637 Y135.94 E.05234
G1 X124.755 Y135.94 E.93928
G2 X123.105 Y136.359 I.021 J3.539 E.27436
G3 X118.119 Y118.117 I-5.293 J-8.356 E5.90272
G3 X123.104 Y119.641 I-.345 J10.046 E.84197
G2 X124.746 Y120.06 I1.701 J-3.239 E.27302
G1 X130.637 Y120.06 E.94065
G1 X130.637 Y135.493 E2.4642
; WIPE_START
G1 X130.637 Y135.94 E-.17016
G1 X129.085 Y135.94 E-.58984
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.666 Y129.836 Z14.24 F42000
G1 X140.7 Y120.461 Z14.24
G1 Z13.84
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X140.718 Y120.06 E.06412
G1 X146.863 Y120.062 E.98124
G3 X148.075 Y121.213 I-.077 J1.294 E.28998
G1 X148.102 Y121.551 E.05406
G2 X140.82 Y120.471 I-11.499 J52.428 E1.1765
; WIPE_START
G1 X140.718 Y120.06 E-.1607
G1 X142.295 Y120.061 E-.5993
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.542 Y127.656 Z14.24 F42000
G1 X140.72 Y135.94 Z14.24
G1 Z13.84
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X140.703 Y135.538 E.06429
G2 X148.104 Y134.45 I-4.201 J-54.267 E1.19534
G1 X148.074 Y134.798 E.05575
G3 X146.778 Y135.94 I-1.287 J-.153 E.30195
G1 X140.84 Y135.94 E.94817
; WIPE_START
G1 X140.703 Y135.538 E-.16147
G1 X142.271 Y135.385 E-.59853
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.644 Y135.087 Z14.24 F42000
G1 X131.337 Y134.957 Z14.24
G1 Z13.84
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X139.301 Y134.936 I3.791 J-71.274 E1.27237
G1 X140.364 Y134.864 E.17014
G1 X140.974 Y134.813 E.09773
G1 X141.582 Y134.759 E.09745
G1 X142.179 Y134.696 E.09581
G1 X142.179 Y134.696 E.00005
G1 X142.776 Y134.633 E.09581
G1 X143.943 Y134.486 E.18778
G1 X145.078 Y134.318 E.18332
G1 F3000
G1 X146.18 Y134.13 E.1784
G1 F2700
G1 X147.244 Y133.923 E.1732
G1 F2400
G1 X148.268 Y133.697 E.16733
G1 F2250
G1 X148.782 Y133.568 E.0847
G1 F3215.099
G1 X148.782 Y133.877 E.04925
G3 X148.755 Y134.977 I-6.759 J.384 E.17589
G3 X146.787 Y136.64 I-1.975 J-.34 E.447
G1 X124.763 Y136.64 E3.51655
M73 P66 R6
G2 X123.437 Y136.976 I.011 J2.835 E.22062
G3 X118.141 Y117.418 I-5.626 J-8.973 E6.31237
G3 X123.437 Y119.025 I-.365 J10.731 E.89369
G2 X124.76 Y119.36 I1.361 J-2.59 E.22005
G1 X146.786 Y119.36 E3.51701
G3 X148.782 Y121.357 I.004 J1.992 E.50092
G1 X148.782 Y122.126 E.12281
G1 X148.782 Y122.43 E.04865
G1 F2100
G1 X148.584 Y122.379 E.03267
G1 F2400
G1 X147.552 Y122.143 E.16901
G1 F2700
G1 X146.476 Y121.926 E.17531
G1 F3000
G1 X145.36 Y121.728 E.18109
G1 F3215.099
G1 X144.206 Y121.551 E.1864
G1 X143.018 Y121.396 E.19123
G1 X142.422 Y121.33 E.09581
G1 X141.801 Y121.262 E.09966
G1 X141.204 Y121.209 E.09581
G1 X141.156 Y121.205 E.00756
G1 X140.559 Y121.151 E.09581
G1 X139.96 Y121.109 E.09581
G1 X139.958 Y121.109 E.00038
G1 X139.359 Y121.068 E.09581
G2 X131.337 Y121.044 I-4.224 J71.384 E1.28168
G1 X131.337 Y121.248 E.03265
G1 X131.337 Y134.752 E2.15626
G1 X131.337 Y134.837 E.01352
; WIPE_START
M204 S6000
G1 X132.823 Y135.021 E-.56906
G1 X133.325 Y135.029 E-.19094
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


G1 X132.791 Y135.83 F42000
G1 Z13.84
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.01243
G1 F2521.713
M204 S6000
G1 X136.624 Y135.843 E.78023
; LINE_WIDTH: 1.03446
G1 F2460.933
G1 X137.903 Y135.824 E.26685
; LINE_WIDTH: 1.06884
G1 F2371.762
G1 X138.541 Y135.808 E.13823
; LINE_WIDTH: 1.09941
G1 F2297.71
G1 X139.171 Y135.793 E.14077
; LINE_WIDTH: 1.13708
G1 F2212.592
G1 X140.362 Y135.753 E.27638
; WIPE_START
G1 X139.171 Y135.793 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.267 Y135.545 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 0.241724
G1 F3000
M204 S6000
G1 X144.598 Y135.521 E.00921
; LINE_WIDTH: 0.288033
G1 X144.929 Y135.496 E.01272
; LINE_WIDTH: 0.334342
G1 X145.261 Y135.472 E.01623
; LINE_WIDTH: 0.381833
G1 X145.549 Y135.448 E.01725
; LINE_WIDTH: 0.430364
G1 X145.834 Y135.423 E.02026
; LINE_WIDTH: 0.478673
G1 X146.119 Y135.399 E.02342
; LINE_WIDTH: 0.526982
G1 X146.404 Y135.375 E.02658
; LINE_WIDTH: 0.568786
G1 X146.588 Y135.357 E.01888
; LINE_WIDTH: 0.603702
G1 X146.767 Y135.34 E.01979
; LINE_WIDTH: 0.625638
G2 X147.157 Y135.251 I-.128 J-1.452 E.04629
; LINE_WIDTH: 0.575546
G1 X147.239 Y135.216 E.00935
; LINE_WIDTH: 0.54379
G1 X147.283 Y135.194 E.00474
; LINE_WIDTH: 0.517478
G1 X147.327 Y135.172 E.00445
; LINE_WIDTH: 0.481146
G1 X147.39 Y135.136 E.00593
; LINE_WIDTH: 0.441781
G1 X147.427 Y135.112 E.00327
; LINE_WIDTH: 0.409453
G1 X147.465 Y135.088 E.00294
; LINE_WIDTH: 0.384178
G1 X147.483 Y135.076 E.00131
; LINE_WIDTH: 0.354247
G1 X147.592 Y134.994 E.00731
; LINE_WIDTH: 0.316878
G1 X147.7 Y134.914 E.00599
; WIPE_START
G1 X147.592 Y134.994 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.644 Y127.362 Z14.24 F42000
G1 X147.686 Y121.058 Z14.24
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 0.420166
G1 F3000
M204 S6000
G1 X147.419 Y120.884 E.02183
; LINE_WIDTH: 0.452608
G1 X147.377 Y120.859 E.00369
; LINE_WIDTH: 0.484694
G1 X147.335 Y120.834 E.00405
; LINE_WIDTH: 0.511476
G1 X147.303 Y120.816 E.00331
; LINE_WIDTH: 0.543532
G1 X147.226 Y120.779 E.00823
; LINE_WIDTH: 0.577729
G1 X147.166 Y120.754 E.00677
; LINE_WIDTH: 0.622281
G2 X146.714 Y120.655 I-.539 J1.376 E.05328
; LINE_WIDTH: 0.585795
G1 X146.482 Y120.634 E.02472
; LINE_WIDTH: 0.545314
G1 X146.25 Y120.614 E.02257
; LINE_WIDTH: 0.504833
G1 X146.018 Y120.594 E.02042
; LINE_WIDTH: 0.464352
G1 X145.787 Y120.573 E.01827
; LINE_WIDTH: 0.423571
G1 X145.551 Y120.552 E.01635
; LINE_WIDTH: 0.380122
G1 X145.233 Y120.528 E.01891
; LINE_WIDTH: 0.334243
G1 X144.916 Y120.504 E.01557
; LINE_WIDTH: 0.288363
G1 X144.598 Y120.48 E.01223
; LINE_WIDTH: 0.242484
G1 X144.28 Y120.456 E.0089
; WIPE_START
G1 X144.598 Y120.48 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.359 Y120.248 Z14.24 F42000
G1 Z13.84
G1 E.8 F1800
; LINE_WIDTH: 1.14192
G1 F2202.113
M204 S6000
G1 X139.341 Y120.212 E.23748
; LINE_WIDTH: 1.10823
G1 F2277.217
G1 X138.696 Y120.196 E.14539
; LINE_WIDTH: 1.07544
G1 F2355.369
G1 X138.042 Y120.18 E.14269
; LINE_WIDTH: 1.03641
G1 F2455.703
G1 X136.518 Y120.157 E.31854
; LINE_WIDTH: 1.01264
G1 F2521.108
G1 X132.755 Y120.171 E.76629
; LINE_WIDTH: 1.05539
G1 F2405.878
G1 X131.871 Y120.19 E.18871
; LINE_WIDTH: 1.08315
G1 F2336.506
G1 X130.987 Y120.209 E.19431
M204 S10000
G1 X130.987 Y135.791 F42000
; LINE_WIDTH: 1.08278
G1 F2337.4
M204 S6000
G1 X131.889 Y135.811 E.1982
; LINE_WIDTH: 1.05446
G1 F2408.265
G1 X132.791 Y135.83 E.19237
; WIPE_START
G1 X131.889 Y135.811 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.719 Y131.318 Z14.24 F42000
G1 X112.21 Y121.482 Z14.24
G1 Z13.84
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.422 Y123.618 I6.68 J7.406 E.44632
G1 X122.193 Y135.389 E2.65804
G3 X119.602 Y136.398 I-4.593 J-7.966 E.4457
G1 X129.342 Y126.658 E2.19949
G1 X129.342 Y129.342 E.42867
G1 X119.603 Y119.603 E2.19923
G3 X122.192 Y120.612 I-2.21 J9.502 E.44519
G1 X110.419 Y132.385 E2.65855
G2 X112.209 Y134.521 I8.197 J-5.052 E.44658
; CHANGE_LAYER
; Z_HEIGHT: 14.4
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.206 Y133.504 E-.54277
G1 X110.878 Y133.036 E-.21723
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 26/51
; update layer progress
M73 L26
M991 S0 P25 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z14.4 I-.194 J1.693 P1  F42000
G1 X130.119 Y135.241 Z14.4
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.746 Y135.241 E.85802
G2 X122.773 Y135.743 I.03 J4.243 E.32818
G3 X118.106 Y118.817 I-4.961 J-7.739 E5.49455
G3 X122.771 Y120.257 I-.334 J9.362 E.78866
G2 X124.731 Y120.76 I2.042 J-3.886 E.32607
G1 X130.119 Y120.76 E.8603
G1 X130.119 Y135.121 E2.29305
M204 S10000
G1 X130.819 Y135.556 F42000
M106 S255
G1 F3215.099
M204 S6000
G1 X130.819 Y135.94 E.06136
G1 X124.755 Y135.94 E.96833
G2 X123.105 Y136.359 I.021 J3.539 E.27443
G3 X118.128 Y118.117 I-5.293 J-8.356 E5.90419
G3 X123.104 Y119.641 I-.354 J10.045 E.84039
G2 X124.746 Y120.06 I1.702 J-3.237 E.27309
G1 X130.819 Y120.06 E.96973
G1 X130.819 Y135.436 E2.45518
; WIPE_START
G1 X130.819 Y135.94 E-.19163
G1 X129.323 Y135.94 E-.56837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.362 Y129.464 Z14.8 F42000
G1 X138.976 Y120.461 Z14.8
G1 Z14.4
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X138.994 Y120.06 E.06413
G1 X146.863 Y120.062 E1.25655
G3 X148.082 Y121.345 I-.075 J1.292 E.31108
G1 X148.082 Y121.972 E.1002
G2 X140.134 Y120.565 I-12.549 J47.712 E1.29029
G1 X139.095 Y120.472 E.16655
; WIPE_START
G1 X138.994 Y120.06 E-.16121
G1 X140.569 Y120.061 E-.59879
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.812 Y127.655 Z14.8 F42000
G1 X138.986 Y135.94 Z14.8
G1 Z14.4
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X138.969 Y135.539 E.06421
G2 X148.082 Y134.025 I-3.584 J-49.769 E1.47728
G1 X148.082 Y134.633 E.09715
G3 X146.778 Y135.94 I-1.293 J.014 E.32837
G1 X139.106 Y135.94 E1.22506
; WIPE_START
G1 X138.969 Y135.539 E-.16135
G1 X140.537 Y135.386 E-.59865
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.916 Y134.961 Z14.8 F42000
G1 X131.519 Y134.884 Z14.8
G1 Z14.4
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.519 Y135.031 E.02354
G2 X137.586 Y134.935 I1.746 J-81.453 E.9692
G1 X138.669 Y134.862 E.17325
G1 X139.267 Y134.81 E.0958
G1 X139.289 Y134.808 E.00365
G1 X139.887 Y134.757 E.0958
G1 X140.484 Y134.693 E.09581
G1 X140.486 Y134.693 E.00032
G1 X141.082 Y134.63 E.09581
M73 P67 R6
G1 X142.25 Y134.481 E.18796
G1 X143.387 Y134.313 E.18347
G1 F3000
G1 X144.489 Y134.124 E.17852
G1 F2700
G1 X145.554 Y133.916 E.1733
G1 F2400
G1 X146.577 Y133.689 E.16736
G1 F2100
G1 X147.556 Y133.444 E.16115
G1 F1800
G1 X148.205 Y133.265 E.1075
G1 F1500
G1 X148.782 Y133.093 E.0961
M106 S198.9
G1 F3000
G1 X148.782 Y133.485 E.06246
M106 S255
G1 F3215.099
G3 X148.779 Y134.768 I-21.774 J.58 E.20491
G3 X146.787 Y136.64 I-1.998 J-.129 E.48049
G1 X124.764 Y136.64 E3.51658
G2 X123.437 Y136.976 I.011 J2.835 E.22066
G3 X118.151 Y117.418 I-5.626 J-8.973 E6.31386
G3 X123.436 Y119.025 I-.375 J10.73 E.89215
G2 X124.76 Y119.36 I1.361 J-2.589 E.2201
G1 X146.786 Y119.36 E3.51704
G3 X148.782 Y121.325 I.004 J1.992 E.49592
G1 X148.782 Y122.514 E.1898
G1 F3000
G1 X148.782 Y122.907 E.06274
G1 F1500
G1 X148.777 Y122.905 E.00092
M106 S198.9
G1 F1650
G1 X147.844 Y122.634 E.15509
G1 F1950
G1 X146.858 Y122.379 E.16261
G1 F2400
G1 X145.825 Y122.142 E.1693
G1 F2700
G1 X144.747 Y121.924 E.17554
G1 F3000
G1 X143.628 Y121.727 E.18138
G1 F3215.099
G1 X142.473 Y121.55 E.18666
G1 X141.283 Y121.394 E.19152
G1 X140.687 Y121.329 E.0958
G1 X140.065 Y121.261 E.09994
G1 X139.467 Y121.208 E.09581
G1 X139.418 Y121.203 E.00785
G1 X138.821 Y121.15 E.09581
G1 X137.649 Y121.069 E.1876
G2 X131.519 Y120.969 I-4.39 J81.848 E.97913
G1 X131.519 Y121.117 E.02355
G1 X131.519 Y134.764 E2.17905
; WIPE_START
M204 S6000
G1 X131.519 Y135.031 E-.10163
G1 X133.251 Y135.055 E-.65837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
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


G1 X134.924 Y135.842 F42000
G1 Z14.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.01001
G1 F2528.552
M204 S6000
G1 X131.169 Y135.832 E.76236
M204 S10000
G1 X134.924 Y135.842 F42000
; LINE_WIDTH: 1.03518
G1 F2459.015
M204 S6000
G1 X136.205 Y135.823 E.2674
; LINE_WIDTH: 1.06995
G1 F2368.999
G1 X136.844 Y135.808 E.13857
; LINE_WIDTH: 1.10078
G1 F2294.501
G1 X137.474 Y135.792 E.14115
; LINE_WIDTH: 1.1375
G1 F2211.683
G1 X138.628 Y135.754 E.26784
; WIPE_START
G1 X137.474 Y135.792 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.545 Y135.545 Z14.8 F42000
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 0.242617
G1 F3000
M204 S6000
G1 X142.887 Y135.52 E.00958
; LINE_WIDTH: 0.290713
G1 X143.229 Y135.494 E.01334
; LINE_WIDTH: 0.338809
G1 X143.571 Y135.469 E.01711
; LINE_WIDTH: 0.387301
G1 X143.859 Y135.445 E.01761
; LINE_WIDTH: 0.436018
G1 X144.144 Y135.42 E.02063
; LINE_WIDTH: 0.484505
G1 X144.429 Y135.396 E.02379
; LINE_WIDTH: 0.532993
G1 X144.714 Y135.372 E.02696
; LINE_WIDTH: 0.579217
G1 X144.942 Y135.35 E.02395
; LINE_WIDTH: 0.62279
G1 X145.164 Y135.328 E.02563
; LINE_WIDTH: 0.665866
G1 X145.387 Y135.307 E.02782
; LINE_WIDTH: 0.708942
G1 X145.609 Y135.285 E.03002
; LINE_WIDTH: 0.752019
G1 X145.832 Y135.264 E.03222
; LINE_WIDTH: 0.79454
G1 X146.024 Y135.243 E.02981
; LINE_WIDTH: 0.835802
G1 X146.209 Y135.223 E.03029
; LINE_WIDTH: 0.876172
G1 F2976.211
G1 X146.393 Y135.202 E.032
; LINE_WIDTH: 0.916542
G1 F2825.338
G1 X146.578 Y135.182 E.03371
; LINE_WIDTH: 0.956912
G1 F2689.024
G1 X146.762 Y135.162 E.03542
; LINE_WIDTH: 0.988808
G1 F2590.283
G2 X147.013 Y135.107 I-.097 J-1.042 E.05108
; LINE_WIDTH: 0.963934
G1 F2666.644
G2 X147.132 Y135.055 I-.364 J-.997 E.02492
; LINE_WIDTH: 0.926736
G1 F2789.63
G1 X147.181 Y135.028 E.0104
; LINE_WIDTH: 0.898457
G1 F2890.99
G1 X147.222 Y135.004 E.00853
; LINE_WIDTH: 0.860237
G1 F3000
G1 X147.281 Y134.964 E.01195
; LINE_WIDTH: 0.81962
G1 X147.733 Y134.628 E.0898
; WIPE_START
G1 X147.281 Y134.964 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z14.8 I1.216 J.041 P1  F42000
G1 X147.732 Y121.491 Z14.8
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 0.523117
G1 F3000
M204 S6000
G1 X147.609 Y121.354 E.01692
; LINE_WIDTH: 0.564177
G1 X147.487 Y121.217 E.01864
; LINE_WIDTH: 0.601875
G1 X147.463 Y121.193 E.00364
; LINE_WIDTH: 0.636204
G1 X147.44 Y121.17 E.0039
; LINE_WIDTH: 0.666655
G1 X147.42 Y121.151 E.00343
; LINE_WIDTH: 0.693231
G1 X147.4 Y121.132 E.0036
; LINE_WIDTH: 0.724682
G1 X147.369 Y121.105 E.0057
; LINE_WIDTH: 0.761013
G1 X147.338 Y121.078 E.00604
; LINE_WIDTH: 0.802708
G1 X147.29 Y121.041 E.00931
; LINE_WIDTH: 0.842597
G1 X147.253 Y121.015 E.0076
; LINE_WIDTH: 0.882275
G1 F2952.378
G1 X147.189 Y120.974 E.01319
; LINE_WIDTH: 0.921761
G1 F2806.943
G1 X147.135 Y120.946 E.01101
; LINE_WIDTH: 0.964295
G1 F2665.505
G2 X147.001 Y120.89 I-.483 J.972 E.02798
; LINE_WIDTH: 0.993813
G1 F2575.443
G2 X146.822 Y120.847 I-.418 J1.345 E.03687
; LINE_WIDTH: 0.97068
G1 F2645.495
G1 X146.648 Y120.827 E.034
; LINE_WIDTH: 0.931395
G1 F2773.606
G1 X146.473 Y120.808 E.03243
; LINE_WIDTH: 0.892111
G1 F2914.757
G1 X146.299 Y120.788 E.03086
; LINE_WIDTH: 0.851786
G1 F3000
G1 X146.116 Y120.767 E.0308
; LINE_WIDTH: 0.808786
G1 X145.891 Y120.745 E.03555
; LINE_WIDTH: 0.7639
G1 X145.666 Y120.722 E.03324
; LINE_WIDTH: 0.719014
G1 X145.441 Y120.699 E.03092
; LINE_WIDTH: 0.674128
G1 X145.215 Y120.677 E.0286
; LINE_WIDTH: 0.628656
G1 X144.984 Y120.654 E.02694
; LINE_WIDTH: 0.585404
G1 X144.752 Y120.633 E.02474
; LINE_WIDTH: 0.544813
G1 X144.52 Y120.613 E.02258
; LINE_WIDTH: 0.504221
G1 X144.288 Y120.593 E.02043
; LINE_WIDTH: 0.46363
G1 X144.056 Y120.572 E.01827
; LINE_WIDTH: 0.422742
G1 X143.82 Y120.552 E.01633
; LINE_WIDTH: 0.379366
G1 X143.504 Y120.528 E.01872
; LINE_WIDTH: 0.333711
G1 X143.189 Y120.504 E.01542
; LINE_WIDTH: 0.288056
G1 X142.873 Y120.48 E.01213
; LINE_WIDTH: 0.242401
G1 X142.557 Y120.456 E.00883
; WIPE_START
G1 X142.873 Y120.48 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.635 Y120.248 Z14.8 F42000
G1 Z14.4
G1 E.8 F1800
; LINE_WIDTH: 1.14141
G1 F2203.212
M204 S6000
G1 X137.601 Y120.212 E.24104
; LINE_WIDTH: 1.10729
G1 F2279.375
G1 X136.956 Y120.196 E.14534
; LINE_WIDTH: 1.07469
G1 F2357.231
G1 X136.302 Y120.179 E.14247
; LINE_WIDTH: 1.03783
G1 F2451.915
G1 X134.992 Y120.159 E.27434
; LINE_WIDTH: 1.01033
G1 F2527.662
G1 X131.169 Y120.169 E.77642
; WIPE_START
G1 X133.169 Y120.164 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.872 Y124.477 Z14.8 F42000
G1 X112.21 Y134.52 Z14.8
G1 Z14.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.676 J-6.579 E.44689
G1 X122.192 Y120.612 E2.6586
G2 X119.603 Y119.603 I-4.802 J8.502 E.44515
G1 X129.524 Y129.524 E2.24029
G1 X129.524 Y126.476 E.48678
G1 X119.602 Y136.398 E2.24052
G2 X122.193 Y135.389 I-1.993 J-8.954 E.44566
G1 X110.422 Y123.618 E2.65802
G3 X112.21 Y121.482 I8.477 J5.276 E.44631
; CHANGE_LAYER
; Z_HEIGHT: 14.96
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57236
G1 X110.875 Y122.964 E-.18764
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 27/51
; update layer progress
M73 L27
M991 S0 P26 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z14.96 I-.818 J1.495 P1  F42000
G1 X130.301 Y133.595 Z14.96
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X130.301 Y135.241 E.26281
G1 X124.746 Y135.241 E.88707
G2 X122.773 Y135.743 I.03 J4.243 E.32825
G3 X118.117 Y118.817 I-4.96 J-7.739 E5.49623
G3 X122.771 Y120.256 I-.345 J9.361 E.7869
G2 X124.731 Y120.76 I2.042 J-3.885 E.32602
G1 X130.301 Y120.76 E.88946
G1 X130.301 Y133.475 E2.03024
; WIPE_START
G1 X130.301 Y135.241 E-.67105
G1 X130.067 Y135.241 E-.08895
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.001 Y134.275 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X131.001 Y135.94 E.26598
G1 X124.755 Y135.94 E.99738
G2 X123.105 Y136.359 I.021 J3.539 E.27447
G3 X118.139 Y118.118 I-5.293 J-8.356 E5.90591
G3 X123.104 Y119.64 I-.365 J10.044 E.83865
G2 X124.745 Y120.06 I1.701 J-3.236 E.27306
G1 X131.001 Y120.06 E.99885
G1 X131.001 Y134.155 E2.25055
; WIPE_START
G1 X131.001 Y135.94 E-.6786
G1 X130.787 Y135.94 E-.0814
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.177 Y130.537 Z15.36 F42000
G1 X145.931 Y120.76 Z15.36
G1 Z14.96
G1 E.8 F1800
G1 F3215.099
M204 S6000
G3 X146.824 Y120.761 I.418 J16.226 E.14266
G3 X147.364 Y121.206 I-.033 J.59 E.1195
G1 X147.444 Y121.561 E.05816
G2 X145.884 Y121.127 I-7.921 J25.419 E.25859
G1 X145.916 Y120.879 E.03989
; WIPE_START
G1 X146.824 Y120.761 E-.3481
G1 X147.029 Y120.81 E-.08017
G1 X147.174 Y120.901 E-.06503
G1 X147.292 Y121.037 E-.06825
G1 X147.364 Y121.206 E-.06981
G1 X147.438 Y121.536 E-.12864
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.878 Y120.486 Z15.36 F42000
G1 X137.266 Y120.123 Z15.36
G1 Z14.96
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X137.269 Y120.06 E.01003
G1 X146.863 Y120.062 E1.53183
M73 P68 R6
G3 X148.082 Y121.342 I-.075 J1.292 E.31064
G1 X148.082 Y122.491 E.18347
G2 X139.632 Y120.698 I-13.347 J42.105 E1.38151
G2 X137.251 Y120.461 I-7.065 J58.904 E.38204
G1 X137.261 Y120.243 E.03494
; WIPE_START
G1 X137.269 Y120.06 E-.06948
G1 X139.086 Y120.06 E-.69052
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.274 Y126.996 Z15.36 F42000
G1 X145.894 Y134.874 Z15.36
G1 Z14.96
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X147.452 Y134.437 I-8.878 J-34.663 E.25836
G1 X147.362 Y134.803 E.06026
G1 X147.3 Y134.95 E.02534
G3 X146.77 Y135.241 I-.514 J-.309 E.10114
G1 X145.941 Y135.241 E.1325
G1 X145.909 Y134.993 E.03991
; WIPE_START
G1 X147.452 Y134.437 E-.62313
G1 X147.366 Y134.787 E-.13687
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.754 Y135.352 Z15.36 F42000
G1 X137.246 Y135.539 Z15.36
G1 Z14.96
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X144.993 Y134.374 I-4.095 J-53.597 E1.25198
M73 P68 R5
G2 X148.082 Y133.51 I-9.516 J-39.948 E.51239
G1 X148.082 Y134.633 E.17943
G3 X146.779 Y135.94 I-1.293 J.015 E.32831
G1 X137.264 Y135.94 E1.51932
G1 X137.251 Y135.659 E.04504
; WIPE_START
G1 X139.229 Y135.358 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.701 Y134.955 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X131.701 Y135.063 E.01727
G2 X135.871 Y134.935 I-1.519 J-117.541 E.66627
G1 X136.973 Y134.86 E.17636
G1 X137.571 Y134.808 E.0958
G1 X137.595 Y134.806 E.00387
G1 X138.193 Y134.754 E.0958
G1 X138.789 Y134.69 E.0958
G1 X138.793 Y134.69 E.00052
G1 X139.389 Y134.626 E.0958
G1 X140.558 Y134.477 E.18813
G1 X141.695 Y134.307 E.18362
G1 F3000
G1 X142.798 Y134.118 E.17865
G1 F2700
G1 X143.864 Y133.909 E.17339
G1 F2400
G1 X144.887 Y133.681 E.16735
G1 F2100
G1 X145.639 Y133.494 E.12372
G1 F1950
G1 X145.867 Y133.435 E.03766
G1 F1800
G1 X146.378 Y133.295 E.08465
G1 F1500
G1 X147.054 Y133.095 E.11248
M106 S198.9
M106 S255
G1 F1380
G1 X147.627 Y132.918 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X148.209 Y132.738 E.09727
M106 S198.9
M106 S255
G1 F1140
G1 X148.782 Y132.561 E.0958
M106 S198.9
G1 F2850
G1 X148.782 Y133.009 E.0715
M106 S255
G1 F3215.099
G3 X148.779 Y134.768 I-29.825 J.818 E.2809
G3 X146.787 Y136.64 I-1.998 J-.129 E.48049
G1 X124.764 Y136.64 E3.5166
G2 X123.437 Y136.976 I.011 J2.835 E.2207
G3 X118.161 Y117.418 I-5.626 J-8.973 E6.31558
G3 X123.436 Y119.025 I-.385 J10.729 E.89041
G2 X124.76 Y119.36 I1.361 J-2.588 E.22011
G1 X146.787 Y119.36 E3.51706
G3 X148.782 Y121.322 I.004 J1.992 E.49532
G1 X148.782 Y122.992 E.26665
G1 F2850
G1 X148.782 Y123.44 E.07151
G1 F1140
G1 X148.209 Y123.262 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X147.626 Y123.082 E.09738
M106 S198.9
M106 S255
G1 F1380
G1 X147.053 Y122.905 E.0958
M106 S198.9
G1 F1650
G1 X146.12 Y122.633 E.15525
G1 F1950
G1 X145.132 Y122.378 E.16294
G1 F2400
G1 X144.097 Y122.141 E.16947
G1 F2700
G1 X143.418 Y122.004 E.11054
G1 F2850
G1 X143.017 Y121.923 E.06532
G1 F3000
G1 X141.897 Y121.726 E.18163
G1 F3215.099
G1 X140.74 Y121.549 E.18694
G1 X140.144 Y121.471 E.096
G1 X139.549 Y121.393 E.09581
G1 X138.952 Y121.328 E.09581
G1 X138.328 Y121.26 E.10023
G1 X137.731 Y121.207 E.0958
G1 X137.68 Y121.202 E.00813
G1 X137.082 Y121.149 E.0958
G1 X135.901 Y121.067 E.18907
G2 X131.701 Y120.938 I-4.332 J72.339 E.67112
G1 X131.701 Y121.046 E.01729
G1 X131.701 Y134.835 E2.2017
; WIPE_START
M204 S6000
G1 X131.701 Y135.063 E-.0867
G1 X133.211 Y135.044 E-.57384
G1 X133.472 Y135.036 E-.09946
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


G1 X133.224 Y135.842 F42000
G1 Z14.96
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.00765
G1 F2535.291
M204 S6000
G1 X131.351 Y135.854 E.37922
M204 S10000
G1 X133.224 Y135.842 F42000
; LINE_WIDTH: 1.03588
G1 F2457.127
M204 S6000
G1 X134.506 Y135.823 E.26796
; LINE_WIDTH: 1.07103
G1 F2366.292
G1 X135.146 Y135.807 E.13891
; LINE_WIDTH: 1.10217
G1 F2291.254
G1 X135.778 Y135.792 E.14153
; LINE_WIDTH: 1.1383
G1 F2209.95
G1 X136.905 Y135.753 E.26208
; WIPE_START
G1 X135.778 Y135.792 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.823 Y135.545 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 0.24348
G1 F3000
M204 S6000
G1 X141.175 Y135.519 E.00994
; LINE_WIDTH: 0.293303
G1 X141.528 Y135.493 E.01395
; LINE_WIDTH: 0.343126
G1 X141.88 Y135.467 E.01797
; LINE_WIDTH: 0.39263
G1 X142.168 Y135.442 E.01801
; LINE_WIDTH: 0.441657
G1 X142.454 Y135.418 E.02104
; LINE_WIDTH: 0.490449
G1 X142.74 Y135.393 E.02424
; LINE_WIDTH: 0.539241
G1 X143.026 Y135.369 E.02743
; LINE_WIDTH: 0.585692
G1 X143.253 Y135.347 E.02426
; LINE_WIDTH: 0.629398
G1 X143.475 Y135.325 E.02593
; LINE_WIDTH: 0.672598
G1 X143.698 Y135.304 E.02813
; LINE_WIDTH: 0.715797
G1 X143.92 Y135.282 E.03034
; LINE_WIDTH: 0.758997
G1 X144.142 Y135.26 E.03254
; LINE_WIDTH: 0.803293
G1 X144.434 Y135.228 E.04583
; LINE_WIDTH: 0.847158
G1 X144.718 Y135.197 E.0474
; LINE_WIDTH: 0.890387
G1 F2921.283
G1 X145.002 Y135.166 E.05021
; LINE_WIDTH: 0.933615
G1 F2766.039
G1 X145.286 Y135.135 E.05303
; LINE_WIDTH: 0.976843
G1 F2626.462
G1 X145.57 Y135.103 E.05585
; WIPE_START
G1 X145.286 Y135.135 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.433 Y127.504 Z15.36 F42000
G1 X145.56 Y120.898 Z15.36
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 0.977588
G1 F2624.178
M204 S6000
G1 X145.27 Y120.865 E.05723
; LINE_WIDTH: 0.936534
G1 F2756.148
G1 X144.979 Y120.833 E.05449
; LINE_WIDTH: 0.895479
G1 F2902.095
G1 X144.688 Y120.8 E.05175
; LINE_WIDTH: 0.85376
G1 F3000
G1 X144.388 Y120.766 E.05053
; LINE_WIDTH: 0.809398
G1 X144.163 Y120.743 E.03566
; LINE_WIDTH: 0.764349
G1 X143.937 Y120.721 E.03333
; LINE_WIDTH: 0.7193
G1 X143.711 Y120.698 E.031
; LINE_WIDTH: 0.674251
G1 X143.486 Y120.676 E.02867
; LINE_WIDTH: 0.628612
G1 X143.254 Y120.653 E.02699
; LINE_WIDTH: 0.585213
G1 X143.022 Y120.632 E.02476
; LINE_WIDTH: 0.544512
G1 X142.789 Y120.612 E.02259
; LINE_WIDTH: 0.503811
G1 X142.557 Y120.592 E.02042
; LINE_WIDTH: 0.463109
G1 X142.324 Y120.571 E.01826
; LINE_WIDTH: 0.422113
G1 X142.089 Y120.551 E.01631
; LINE_WIDTH: 0.378768
G1 X141.775 Y120.527 E.01855
; LINE_WIDTH: 0.33329
G1 X141.462 Y120.503 E.01529
; LINE_WIDTH: 0.287813
G1 X141.148 Y120.48 E.01203
; LINE_WIDTH: 0.242336
G1 X140.834 Y120.456 E.00876
; WIPE_START
G1 X141.148 Y120.48 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.91 Y120.248 Z15.36 F42000
G1 Z14.96
G1 E.8 F1800
; LINE_WIDTH: 1.1409
M73 P69 R5
G1 F2204.325
M204 S6000
G1 X135.861 Y120.211 E.24462
; LINE_WIDTH: 1.10635
G1 F2281.548
G1 X135.215 Y120.195 E.14539
; LINE_WIDTH: 1.07385
G1 F2359.289
G1 X134.56 Y120.179 E.14253
; LINE_WIDTH: 1.0372
G1 F2453.583
G1 X133.248 Y120.159 E.27452
; LINE_WIDTH: 1.00786
G1 F2534.685
G1 X131.351 Y120.147 E.38426
; WIPE_START
G1 X133.248 Y120.159 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.631 Y120.638 Z15.36 F42000
G1 X112.21 Y121.482 Z15.36
G1 Z14.96
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.423 Y123.619 I6.699 J7.42 E.4463
G1 X122.193 Y135.389 E2.65799
G3 X119.602 Y136.398 I-4.576 J-7.927 E.44563
G1 X129.706 Y126.294 E2.28157
G1 X129.706 Y129.706 E.54489
G1 X119.604 Y119.604 E2.28134
G3 X122.192 Y120.612 I-2.218 J9.523 E.44512
G1 X110.419 Y132.385 E2.6586
G2 X112.21 Y134.52 I7.462 J-4.441 E.44689
; CHANGE_LAYER
; Z_HEIGHT: 15.52
; LAYER_HEIGHT: 0.56
; WIPE_START
G1 F3215.099
G1 X111.209 Y133.507 E-.54124
G1 X110.877 Y133.036 E-.21876
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 28/51
; update layer progress
M73 L28
M991 S0 P27 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z15.52 I-.191 J1.693 P1  F42000
G1 X130.453 Y135.241 Z15.52
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.746 Y135.241 E.91136
G2 X122.772 Y135.743 I.03 J4.243 E.32835
G3 X118.126 Y118.817 I-4.96 J-7.739 E5.49756
G3 X122.77 Y120.256 I-.355 J9.36 E.78534
G2 X124.73 Y120.76 I2.043 J-3.883 E.32608
G1 X130.483 Y120.76 E.91854
G1 X130.483 Y135.15 E2.29781
M204 S10000
G1 X131.183 Y135.778 F42000
G1 F3215.099
M204 S6000
G1 X131.183 Y135.94 E.02589
G1 X124.755 Y135.94 E1.02643
G2 X123.104 Y136.36 I.021 J3.539 E.27455
G3 X118.148 Y118.118 I-5.293 J-8.356 E5.90725
G3 X123.103 Y119.64 I-.374 J10.043 E.83711
G2 X124.745 Y120.06 I1.702 J-3.235 E.27311
G1 X131.183 Y120.06 E1.02792
G1 X131.183 Y135.658 E2.49065
; WIPE_START
G1 X131.183 Y135.94 E-.10721
G1 X129.465 Y135.94 E-.65279
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.84 Y130.522 Z15.92 F42000
G1 X144.161 Y121.127 Z15.92
G1 Z15.52
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X144.207 Y120.76 E.05906
G1 X146.824 Y120.761 E.41784
G1 X147.022 Y120.807 E.03253
G1 X147.174 Y120.901 E.02849
G1 X147.301 Y121.053 E.03163
G1 X147.368 Y121.225 E.02941
G3 X147.382 Y121.362 I-.56 J.125 E.02208
G1 X147.382 Y122.075 E.11382
G2 X144.277 Y121.157 I-17.69 J54.179 E.51713
; WIPE_START
G1 X144.207 Y120.76 E-.15333
G1 X145.804 Y120.761 E-.60667
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.174 Y120.538 Z15.92 F42000
G1 X135.527 Y120.461 Z15.92
G1 Z15.52
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X135.545 Y120.06 E.06414
G1 X146.863 Y120.062 E1.80714
G3 X148.082 Y121.34 I-.072 J1.289 E.31059
G1 X148.082 Y123.023 E.26875
G2 X144.58 Y121.958 I-34.471 J107.03 E.58458
G2 X135.647 Y120.47 I-12.651 J48.397 E1.44801
; WIPE_START
G1 X135.545 Y120.06 E-.16057
G1 X137.122 Y120.06 E-.59943
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.352 Y126.976 Z15.92 F42000
G1 X144.211 Y135.241 Z15.92
G1 Z15.52
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X144.165 Y134.872 E.05924
G2 X147.383 Y133.926 I-15.811 J-59.672 E.53554
G1 X147.383 Y134.623 E.11131
G3 X146.77 Y135.241 I-.596 J.021 E.15563
G1 X144.331 Y135.241 E.38945
; WIPE_START
G1 X144.165 Y134.872 E-.15343
G1 X145.002 Y134.651 E-.3287
G1 X145.701 Y134.438 E-.27787
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.151 Y135.555 Z15.92 F42000
G1 X135.542 Y135.94 Z15.92
G1 Z15.52
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X135.524 Y135.539 E.06418
G2 X144.81 Y133.978 I-3.573 J-49.659 E1.50581
G2 X148.082 Y132.977 I-36.621 J-125.579 E.54642
G1 X148.082 Y134.633 E.26448
G3 X146.779 Y135.94 I-1.3 J.007 E.32779
G1 X135.662 Y135.94 E1.77514
; WIPE_START
G1 X135.524 Y135.539 E-.16129
G1 X137.092 Y135.385 E-.59871
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.883 Y135.032 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G2 X134.156 Y134.934 I-2.37 J-81.553 E.36339
G1 X135.277 Y134.858 E.17943
G1 X135.875 Y134.806 E.09581
G1 X135.901 Y134.803 E.00409
G1 X136.498 Y134.751 E.09581
G1 X137.095 Y134.687 E.0958
G1 X137.099 Y134.687 E.00071
G1 X137.696 Y134.623 E.0958
G1 X138.866 Y134.473 E.18831
G1 X140.004 Y134.302 E.18377
G1 F3000
G1 X141.107 Y134.112 E.17877
G1 F2700
G1 X142.173 Y133.902 E.17339
G1 F2550
G1 X142.778 Y133.769 E.09898
G1 F2400
G1 X143.198 Y133.673 E.06876
G1 F2100
G1 X144.175 Y133.427 E.16095
G1 F1800
G1 X144.618 Y133.305 E.07335
G1 F1500
G1 X145.33 Y133.095 E.1185
M106 S198.9
M106 S255
G1 F1380
G1 X145.903 Y132.918 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X147.056 Y132.562 E.19267
M106 S198.9
M106 S255
G1 F1140
G1 X148.782 Y132.028 E.28847
M106 S198.9
G1 F2850
G1 X148.782 Y132.476 E.0715
M106 S255
G1 F3215.099
G1 X148.782 Y134.644 E.34614
G3 X146.787 Y136.64 I-2.003 J-.006 E.50009
G1 X124.764 Y136.64 E3.51662
G2 X123.437 Y136.976 I.011 J2.835 E.22073
G3 X118.171 Y117.419 I-5.625 J-8.973 E6.31696
G3 X123.436 Y119.024 I-.395 J10.728 E.88889
G2 X124.76 Y119.36 I1.361 J-2.587 E.22014
G1 X146.787 Y119.36 E3.51708
G3 X148.782 Y121.319 I-.002 J1.997 E.49447
G1 X148.782 Y123.524 E.35217
G1 F2850
G1 X148.782 Y123.972 E.07151
G1 F1140
G1 X148.209 Y123.795 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X146.672 Y123.32 E.25693
M106 S198.9
M106 S255
G1 F1380
G1 X145.33 Y122.905 E.22427
M106 S198.9
G1 F1650
G1 X144.394 Y122.633 E.15553
G1 F1950
G1 X143.405 Y122.377 E.16312
G1 F2250
G1 X142.798 Y122.238 E.09958
G1 F2400
G1 X142.369 Y122.14 E.07019
G1 F2700
G1 X141.288 Y121.922 E.17606
G1 F3000
G1 X140.166 Y121.724 E.18193
G1 F3215.099
G1 X139.007 Y121.547 E.18722
G1 X138.409 Y121.469 E.09629
G1 X137.814 Y121.392 E.0958
G1 X137.218 Y121.327 E.09581
G1 X136.592 Y121.258 E.1005
G1 X135.994 Y121.205 E.0958
G1 X135.942 Y121.201 E.00841
G1 X135.344 Y121.148 E.0958
G1 X134.172 Y121.067 E.18761
G2 X131.883 Y120.968 I-4.796 J84.661 E.3659
G1 X131.883 Y121.021 E.00842
G1 X131.883 Y134.912 E2.21809
; WIPE_START
M204 S6000
G1 X133.883 Y134.932 E-.76
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


G1 X134.081 Y135.791 F42000
G1 Z15.52
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 1.10356
G1 F2288.016
M204 S6000
G1 X133.448 Y135.806 E.14191
; LINE_WIDTH: 1.07216
G1 F2363.495
G1 X132.808 Y135.822 E.13927
; LINE_WIDTH: 1.04383
G1 F2435.985
G1 X131.533 Y135.842 E.26866
M204 S10000
G1 X134.081 Y135.791 F42000
; LINE_WIDTH: 1.13909
G1 F2208.244
M204 S6000
G1 X135.183 Y135.753 E.25641
; WIPE_START
G1 X134.081 Y135.791 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.101 Y135.545 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 0.237927
G1 F3000
M204 S6000
G1 X139.373 Y135.525 E.00733
; LINE_WIDTH: 0.276644
G1 X139.646 Y135.504 E.00975
; LINE_WIDTH: 0.315361
G1 X139.918 Y135.484 E.01216
; LINE_WIDTH: 0.354078
G1 X140.19 Y135.464 E.01457
; LINE_WIDTH: 0.398147
G1 X140.479 Y135.439 E.01837
; LINE_WIDTH: 0.447375
G1 X140.765 Y135.415 E.02141
; LINE_WIDTH: 0.49636
G1 X141.05 Y135.39 E.02462
; LINE_WIDTH: 0.545345
G1 X141.336 Y135.366 E.02783
; LINE_WIDTH: 0.591947
G1 X141.563 Y135.344 E.02458
; LINE_WIDTH: 0.635787
G1 X141.785 Y135.322 E.02623
; LINE_WIDTH: 0.67911
G1 X142.007 Y135.3 E.02844
; LINE_WIDTH: 0.722433
G1 X142.229 Y135.279 E.03064
; LINE_WIDTH: 0.765756
G1 X142.451 Y135.257 E.03285
; LINE_WIDTH: 0.809397
G1 X142.736 Y135.226 E.04506
; LINE_WIDTH: 0.851777
M73 P70 R5
G1 X143.012 Y135.195 E.04641
; LINE_WIDTH: 0.893514
G1 F2909.468
G1 X143.289 Y135.165 E.04906
; LINE_WIDTH: 0.935251
G1 F2760.485
G1 X143.565 Y135.134 E.05171
; LINE_WIDTH: 0.976988
G1 F2626.015
G1 X143.841 Y135.104 E.05436
; WIPE_START
G1 X143.565 Y135.134 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.718 Y134.849 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 0.243991
G1 F3000
M204 S6000
G1 X145.892 Y134.823 E.00495
; LINE_WIDTH: 0.293639
G1 X146.065 Y134.796 E.00693
; LINE_WIDTH: 0.343288
G1 X146.238 Y134.77 E.00892
; LINE_WIDTH: 0.392936
G1 X146.411 Y134.744 E.0109
; LINE_WIDTH: 0.442585
G1 X146.585 Y134.718 E.01289
; LINE_WIDTH: 0.492233
G1 X146.758 Y134.692 E.01487
; LINE_WIDTH: 0.522344
G1 X146.807 Y134.682 E.00463
; WIPE_START
G1 X146.758 Y134.692 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z15.92 I1.217 J.006 P1  F42000
G1 X146.828 Y121.33 Z15.92
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 0.52353
G1 F3000
M204 S6000
G1 X146.785 Y121.313 E.00426
; LINE_WIDTH: 0.502308
G1 X146.632 Y121.29 E.01344
; LINE_WIDTH: 0.458763
G1 X146.48 Y121.267 E.01191
; LINE_WIDTH: 0.415218
G1 X146.327 Y121.244 E.01038
; LINE_WIDTH: 0.371673
G1 X146.175 Y121.221 E.00885
; LINE_WIDTH: 0.328128
G1 X146.022 Y121.198 E.00732
; LINE_WIDTH: 0.284582
G1 X145.87 Y121.175 E.00578
; LINE_WIDTH: 0.241037
G1 X145.718 Y121.152 E.00425
; WIPE_START
G1 X145.87 Y121.175 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.837 Y120.898 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 0.977467
G1 F2624.55
M204 S6000
G1 X143.545 Y120.865 E.05747
; LINE_WIDTH: 0.93615
G1 F2757.445
G1 X143.253 Y120.832 E.0547
; LINE_WIDTH: 0.894833
G1 F2904.517
G1 X142.961 Y120.799 E.05193
; LINE_WIDTH: 0.85285
G1 F3000
G1 X142.66 Y120.765 E.05067
; LINE_WIDTH: 0.808362
G1 X142.434 Y120.743 E.03563
; LINE_WIDTH: 0.763303
G1 X142.208 Y120.72 E.0333
; LINE_WIDTH: 0.718244
G1 X141.982 Y120.698 E.03096
; LINE_WIDTH: 0.673185
G1 X141.757 Y120.675 E.02863
; LINE_WIDTH: 0.627538
G1 X141.525 Y120.652 E.02695
; LINE_WIDTH: 0.584129
G1 X141.292 Y120.632 E.02474
; LINE_WIDTH: 0.543397
G1 X141.059 Y120.611 E.02256
; LINE_WIDTH: 0.502666
G1 X140.827 Y120.591 E.02039
; LINE_WIDTH: 0.461934
G1 X140.594 Y120.571 E.01822
; LINE_WIDTH: 0.420922
G1 X140.358 Y120.55 E.01626
; LINE_WIDTH: 0.377593
G1 X140.046 Y120.526 E.01835
; LINE_WIDTH: 0.33216
G1 X139.735 Y120.503 E.01511
; LINE_WIDTH: 0.286727
G1 X139.423 Y120.479 E.01187
; LINE_WIDTH: 0.241294
G1 X139.112 Y120.455 E.00863
; WIPE_START
G1 X139.423 Y120.479 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.186 Y120.247 Z15.92 F42000
G1 Z15.52
G1 E.8 F1800
; LINE_WIDTH: 1.14037
G1 F2205.469
M204 S6000
G1 X134.12 Y120.211 E.24822
; LINE_WIDTH: 1.1054
G1 F2283.749
G1 X133.474 Y120.195 E.14543
; LINE_WIDTH: 1.07303
G1 F2361.321
G1 X132.818 Y120.178 E.14256
; LINE_WIDTH: 1.04399
G1 F2435.556
G1 X131.533 Y120.159 E.27096
; WIPE_START
G1 X132.818 Y120.178 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.553 Y124.538 Z15.92 F42000
G1 X112.21 Y134.52 Z15.92
G1 Z15.52
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.649 J-6.56 E.4469
G1 X122.192 Y120.612 E2.65861
G2 X119.604 Y119.604 I-4.809 J8.523 E.44509
G1 X129.888 Y129.888 E2.3224
G1 X129.888 Y126.112 E.60299
G1 X119.603 Y136.397 E2.32261
G2 X122.193 Y135.389 I-1.978 J-8.916 E.44559
G1 X110.423 Y123.619 E2.65796
G3 X112.212 Y121.484 I8.393 J5.216 E.44627
; CHANGE_LAYER
; Z_HEIGHT: 16.08
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.5722
G1 X110.875 Y122.964 E-.1878
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 29/51
; update layer progress
M73 L29
M991 S0 P28 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z16.08 I-.9 J1.447 P1  F42000
G1 X130.618 Y135.241 Z16.08
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.746 Y135.241 E.93764
G2 X122.772 Y135.743 I.03 J4.243 E.32839
G3 X118.136 Y118.818 I-4.959 J-7.739 E5.49911
G3 X122.77 Y120.256 I-.365 J9.359 E.78364
G2 X124.73 Y120.76 I2.043 J-3.882 E.32615
G1 X130.665 Y120.76 E.94762
G1 X130.665 Y135.168 E2.30057
M204 S10000
G1 X131.365 Y135.735 F42000
G1 F3215.099
M204 S6000
G1 X131.365 Y135.94 E.03287
G1 X124.755 Y135.94 E1.05548
G2 X123.104 Y136.36 I.02 J3.538 E.27458
G3 X118.158 Y118.118 I-5.292 J-8.356 E5.9088
G3 X123.103 Y119.64 I-.384 J10.042 E.83544
G2 X124.745 Y120.06 I1.702 J-3.233 E.27317
G1 X131.365 Y120.06 E1.05699
G1 X131.365 Y135.615 E2.48366
; WIPE_START
G1 X131.365 Y135.94 E-.12383
G1 X129.691 Y135.94 E-.63617
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.669 Y130.155 Z16.48 F42000
G1 X142.437 Y121.127 Z16.48
G1 Z16.08
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X142.484 Y120.76 E.05905
G1 X146.824 Y120.761 E.69294
G1 X146.955 Y120.783 E.02119
G1 X147.096 Y120.844 E.0245
G1 X147.221 Y120.946 E.02574
G1 X147.312 Y121.072 E.02485
G3 X147.383 Y121.376 I-.552 J.289 E.05041
G1 X147.383 Y122.607 E.19657
G2 X143.041 Y121.283 I-42.776 J132.448 E.72486
G1 X142.554 Y121.157 E.08034
; WIPE_START
G1 X142.484 Y120.76 E-.15313
G1 X144.081 Y120.76 E-.60687
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.452 Y120.538 Z16.48 F42000
G1 X133.803 Y120.461 Z16.48
G1 Z16.08
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X133.821 Y120.06 E.06415
G1 X146.862 Y120.062 E2.08243
G3 X148.082 Y121.366 I-.072 J1.29 E.31481
G1 X148.082 Y123.556 E.34965
G1 X143.807 Y122.235 E.71452
G2 X136.162 Y120.696 I-12.666 J43.15 E1.24675
G2 X133.922 Y120.471 I-6.973 J58.271 E.35945
; WIPE_START
G1 X133.821 Y120.06 E-.16087
G1 X135.397 Y120.06 E-.59913
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.627 Y126.976 Z16.48 F42000
G1 X142.486 Y135.241 Z16.48
G1 Z16.08
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X142.44 Y134.873 E.05921
G2 X144.01 Y134.435 I-7.097 J-28.509 E.26023
G1 X147.383 Y133.393 E.56362
G1 X147.383 Y134.623 E.19632
G3 X146.771 Y135.241 I-.596 J.021 E.15559
G1 X142.606 Y135.241 E.66493
; WIPE_START
G1 X142.44 Y134.873 E-.15338
G1 X143.978 Y134.444 E-.60662
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.427 Y135.556 Z16.48 F42000
G1 X133.82 Y135.94 Z16.48
G1 Z16.08
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X133.802 Y135.539 E.06417
G2 X143.05 Y133.988 I-3.592 J-49.769 E1.49946
G1 X148.082 Y132.444 E.84053
G1 X148.082 Y134.633 E.3495
G3 X146.779 Y135.94 I-1.3 J.008 E.32782
G1 X133.94 Y135.94 E2.05008
; WIPE_START
G1 X133.802 Y135.539 E-.16127
G1 X135.37 Y135.384 E-.59873
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.065 Y134.96 Z16.48 F42000
G1 Z16.08
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.442 Y134.934 E.06035
G1 X133.582 Y134.856 E.18245
G1 X134.179 Y134.803 E.0958
G1 X134.206 Y134.801 E.0043
G1 X134.804 Y134.748 E.0958
G1 X135.4 Y134.684 E.0958
G1 X135.405 Y134.683 E.00078
G1 X136.002 Y134.619 E.0958
G1 X136.245 Y134.589 E.03905
G1 X137.174 Y134.468 E.1496
G1 X138.313 Y134.297 E.18389
G1 F3000
G1 X139.416 Y134.106 E.1789
G1 F2700
G1 X140.483 Y133.895 E.17359
G1 F2400
G1 X141.507 Y133.665 E.16755
G1 F2100
G1 X142.485 Y133.418 E.16109
G1 F1800
G1 X142.858 Y133.315 E.06184
G1 F1650
G1 X143.606 Y133.095 E.12452
G1 F1380
G1 X144.18 Y132.918 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X146.194 Y132.295 E.3367
M106 S198.9
M106 S255
G1 F1140
G1 X148.782 Y131.496 E.4325
M106 S198.9
G1 F2850
G1 X148.782 Y131.944 E.0715
M106 S255
G1 F3215.099
G1 X148.782 Y134.644 E.43118
G3 X146.787 Y136.64 I-2.002 J-.006 E.50016
G1 X124.764 Y136.64 E3.51657
G2 X123.436 Y136.976 I.011 J2.835 E.22078
G3 X118.181 Y117.419 I-5.625 J-8.973 E6.3185
G3 X123.436 Y119.024 I-.405 J10.728 E.88726
G2 X124.76 Y119.36 I1.361 J-2.586 E.22017
G1 X146.787 Y119.36 E3.51709
G3 X148.782 Y121.356 I-.002 J1.998 E.50049
G1 X148.782 Y124.057 E.4312
G1 F2850
G1 X148.782 Y124.505 E.0715
G1 F1140
G1 X148.209 Y124.328 E.0958
M106 S198.9
M106 S255
G1 F1260
G1 X145.523 Y123.497 E.44897
M106 S198.9
M106 S255
G1 F1380
G1 X143.606 Y122.905 E.32029
M106 S198.9
G1 F1650
G1 X142.67 Y122.633 E.15574
M73 P71 R5
G1 F1950
G1 X142.133 Y122.494 E.08848
G1 F2100
G1 X141.679 Y122.376 E.07491
G1 F2400
G1 X140.641 Y122.139 E.16997
G1 F2700
G1 X139.559 Y121.921 E.17634
G1 F3000
G1 X138.435 Y121.723 E.18219
G1 F3215.099
G1 X137.274 Y121.546 E.18745
G1 X136.981 Y121.507 E.04722
G1 X136.079 Y121.39 E.1452
G1 X135.483 Y121.325 E.0958
G1 X134.855 Y121.257 E.10078
G1 X134.258 Y121.204 E.0958
G1 X134.204 Y121.199 E.00869
G1 X133.606 Y121.147 E.0958
G1 X132.443 Y121.067 E.18619
G1 X132.065 Y121.041 E.06051
G1 X132.065 Y121.055 E.00229
G1 X132.065 Y134.84 E2.20113
; WIPE_START
M204 S6000
G1 X132.442 Y134.934 E-.14769
G1 X133.582 Y134.856 E-.4342
G1 X134.049 Y134.815 E-.17811
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


G1 X137.38 Y135.545 F42000
G1 Z16.08
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.23858
G1 F3000
M204 S6000
G1 X137.66 Y135.524 E.00758
; LINE_WIDTH: 0.278597
G1 X137.94 Y135.503 E.01014
; LINE_WIDTH: 0.318613
G1 X138.219 Y135.482 E.01271
; LINE_WIDTH: 0.358629
G1 X138.499 Y135.461 E.01527
; LINE_WIDTH: 0.403487
G1 X138.788 Y135.436 E.01876
; LINE_WIDTH: 0.453005
G1 X139.075 Y135.412 E.02182
; LINE_WIDTH: 0.502273
G1 X139.361 Y135.387 E.02505
; LINE_WIDTH: 0.551543
G1 X139.647 Y135.363 E.02828
; LINE_WIDTH: 0.598429
G1 X139.875 Y135.34 E.02498
; LINE_WIDTH: 0.642541
G1 X140.098 Y135.318 E.02663
; LINE_WIDTH: 0.686122
G1 X140.32 Y135.297 E.02886
; LINE_WIDTH: 0.729704
G1 X140.542 Y135.275 E.03108
; LINE_WIDTH: 0.773286
G1 X140.765 Y135.253 E.0333
; LINE_WIDTH: 0.816307
G1 X141.042 Y135.222 E.04429
; LINE_WIDTH: 0.85714
G1 X141.311 Y135.193 E.04545
; LINE_WIDTH: 0.897328
G1 F2895.192
G1 X141.579 Y135.163 E.04793
; LINE_WIDTH: 0.937515
G1 F2752.838
G1 X141.848 Y135.133 E.05041
; LINE_WIDTH: 0.977703
G1 F2623.827
G1 X142.117 Y135.103 E.05289
; WIPE_START
G1 X141.848 Y135.133 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.995 Y134.849 Z16.48 F42000
G1 Z16.08
G1 E.8 F1800
; LINE_WIDTH: 0.243276
G1 F3000
M204 S6000
G1 X144.185 Y134.82 E.00539
; LINE_WIDTH: 0.29137
G1 X144.375 Y134.791 E.0075
; LINE_WIDTH: 0.339464
G1 X144.564 Y134.763 E.00961
; LINE_WIDTH: 0.387558
G1 X144.754 Y134.734 E.01171
; LINE_WIDTH: 0.435652
G1 X144.944 Y134.705 E.01382
; LINE_WIDTH: 0.483746
G1 X145.134 Y134.677 E.01593
; LINE_WIDTH: 0.53184
G1 X145.324 Y134.648 E.01804
; LINE_WIDTH: 0.579934
G1 X145.514 Y134.62 E.02014
; LINE_WIDTH: 0.628028
G1 X145.704 Y134.591 E.02225
; LINE_WIDTH: 0.676122
G1 X145.894 Y134.562 E.02436
; LINE_WIDTH: 0.724216
G1 X146.083 Y134.534 E.02647
; LINE_WIDTH: 0.77231
G1 X146.273 Y134.505 E.02857
; LINE_WIDTH: 0.820404
G1 X146.463 Y134.476 E.03068
; LINE_WIDTH: 0.868498
G1 X146.653 Y134.448 E.03279
; LINE_WIDTH: 0.916592
G1 F2825.162
G1 X146.843 Y134.419 E.03489
; LINE_WIDTH: 0.964685
G1 F2664.272
G1 X147.033 Y134.39 E.037
; WIPE_START
G1 X146.843 Y134.419 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z16.48 I1.217 J.018 P1  F42000
G1 X147.033 Y121.61 Z16.48
G1 Z16.08
G1 E.8 F1800
; LINE_WIDTH: 0.964289
G1 F2665.524
M204 S6000
G1 X146.843 Y121.582 E.03699
; LINE_WIDTH: 0.916226
G1 F2826.458
G1 X146.653 Y121.553 E.03488
; LINE_WIDTH: 0.868164
G1 F3000
G1 X146.463 Y121.524 E.03278
; LINE_WIDTH: 0.820102
G1 X146.273 Y121.496 E.03067
; LINE_WIDTH: 0.772039
G1 X146.083 Y121.467 E.02857
; LINE_WIDTH: 0.723977
G1 X145.893 Y121.438 E.02646
; LINE_WIDTH: 0.675914
G1 X145.703 Y121.41 E.02435
; LINE_WIDTH: 0.627852
G1 X145.513 Y121.381 E.02225
; LINE_WIDTH: 0.57979
G1 X145.324 Y121.353 E.02014
; LINE_WIDTH: 0.531727
G1 X145.134 Y121.324 E.01804
; LINE_WIDTH: 0.483665
G1 X144.944 Y121.295 E.01593
; LINE_WIDTH: 0.435602
G1 X144.754 Y121.267 E.01382
; LINE_WIDTH: 0.38754
G1 X144.564 Y121.238 E.01172
; LINE_WIDTH: 0.339478
G1 X144.374 Y121.209 E.00961
; LINE_WIDTH: 0.291415
G1 X144.184 Y121.181 E.0075
; LINE_WIDTH: 0.243353
G1 X143.994 Y121.152 E.0054
; WIPE_START
G1 X144.184 Y121.181 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.114 Y120.898 Z16.48 F42000
G1 Z16.08
G1 E.8 F1800
; LINE_WIDTH: 0.97741
G1 F2624.723
M204 S6000
G1 X141.821 Y120.865 E.05769
; LINE_WIDTH: 0.935852
G1 F2758.451
G1 X141.528 Y120.832 E.05489
; LINE_WIDTH: 0.894294
G1 F2906.537
G1 X141.234 Y120.799 E.0521
; LINE_WIDTH: 0.85207
G1 F3000
G1 X140.932 Y120.765 E.05081
; LINE_WIDTH: 0.807437
G1 X140.706 Y120.742 E.03565
; LINE_WIDTH: 0.762326
G1 X140.48 Y120.72 E.03331
; LINE_WIDTH: 0.717215
G1 X140.253 Y120.697 E.03097
; LINE_WIDTH: 0.672104
G1 X140.027 Y120.675 E.02863
; LINE_WIDTH: 0.626406
G1 X139.795 Y120.652 E.02694
; LINE_WIDTH: 0.582946
G1 X139.562 Y120.631 E.02471
; LINE_WIDTH: 0.542184
G1 X139.329 Y120.611 E.02253
; LINE_WIDTH: 0.501422
G1 X139.096 Y120.59 E.02036
; LINE_WIDTH: 0.46066
G1 X138.863 Y120.57 E.01818
; LINE_WIDTH: 0.419618
G1 X138.626 Y120.549 E.01621
; LINE_WIDTH: 0.376434
G1 X138.317 Y120.526 E.01816
; LINE_WIDTH: 0.331332
G1 X138.007 Y120.502 E.01496
; LINE_WIDTH: 0.28623
G1 X137.697 Y120.479 E.01177
; LINE_WIDTH: 0.241128
G1 X137.388 Y120.455 E.00857
; WIPE_START
G1 X137.697 Y120.479 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.071 Y120.78 Z16.48 F42000
G1 X112.212 Y121.484 Z16.48
G1 Z16.08
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.423 Y123.619 I6.604 J7.351 E.44626
G1 X122.193 Y135.389 E2.65793
G3 X119.603 Y136.397 I-4.558 J-7.884 E.44556
G1 X130.07 Y125.93 E2.36364
G1 X130.07 Y130.07 E.6611
G1 X119.604 Y119.604 E2.36346
G3 X122.192 Y120.612 I-2.226 J9.543 E.44505
G1 X110.419 Y132.385 E2.65861
G2 X112.21 Y134.52 I7.434 J-4.421 E.4469
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 16.64
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.214 Y133.513 E-.53832
G1 X110.878 Y133.036 E-.22168
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 30/51
; update layer progress
M73 L30
M991 S0 P29 ;notify layer change
M106 S255
; OBJECT_ID: 15
M204 S10000
G17
G3 Z16.64 I-.142 J1.698 P1  F42000
G1 X132.247 Y134.822 Z16.64
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.247 Y121.179 E2.17852
G1 X133.119 Y121.256 E.13985
G1 X133.748 Y121.324 E.10108
G1 X134.345 Y121.389 E.0958
G1 X134.946 Y121.467 E.09684
G1 X135.541 Y121.545 E.0958
G1 X136.704 Y121.722 E.18777
G1 F3000
G1 X137.829 Y121.92 E.18244
G1 F2700
G1 X138.559 Y122.067 E.11891
G1 F2550
G1 X138.914 Y122.138 E.05774
G1 F2400
G1 X139.953 Y122.376 E.17021
G1 F1950
G1 X140.945 Y122.632 E.16365
G1 F1650
G1 X141.882 Y122.905 E.15588
G1 F1380
G1 X144.272 Y123.644 E.39936
M106 S196.35
M106 S255
G1 F1260
G1 X147.905 Y124.766 E.60711
M106 S196.35
M106 S255
G1 F1140
G1 X148.478 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X148.478 Y125.258 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X148.478 Y130.742 E.87558
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X148.478 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X148.096 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X146.088 Y131.796 E.33546
M106 S196.35
M106 S255
G1 F1260
G1 X142.456 Y132.918 E.60706
M106 S196.35
M106 S255
G1 F1380
G1 X141.883 Y133.095 E.0958
M106 S196.35
G1 F1650
G1 X141.098 Y133.325 E.13054
G1 F1800
G1 X140.794 Y133.409 E.05032
G1 F2100
G1 X139.817 Y133.657 E.1611
G1 F2400
G1 X138.793 Y133.888 E.16755
G1 F2700
G1 X138.047 Y134.037 E.12143
G1 F2850
G1 X137.725 Y134.1 E.05247
G1 F3000
G1 X136.621 Y134.292 E.17887
G1 F3215.099
G1 X135.481 Y134.464 E.18406
G1 X134.42 Y134.602 E.17094
G1 X133.823 Y134.667 E.0958
G1 X133.139 Y134.743 E.10991
G1 X132.366 Y134.811 E.1239
; WIPE_START
M204 S6000
G1 X132.349 Y132.812 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.76 Y134.634 Z17.04 F42000
G1 X140.723 Y134.871 Z17.04
G1 Z16.64
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G2 X142.287 Y134.435 I-6.907 J-27.809 E.25925
G1 X147.383 Y132.861 E.85164
G1 X147.383 Y134.623 E.28138
G3 X146.828 Y135.238 I-.593 J.023 E.14646
G1 X140.769 Y135.239 E.96742
G1 X140.738 Y134.99 E.04003
; WIPE_START
G1 X142.287 Y134.435 E-.62522
G1 X142.626 Y134.331 E-.13478
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.043 Y135.2 Z17.04 F42000
G1 X132.094 Y135.538 Z17.04
G1 Z16.64
G1 E.8 F1800
G1 F3215.099
M204 S6000
G2 X141.289 Y133.999 I-3.605 J-49.757 E1.49089
G1 X148.082 Y131.912 E1.13477
G1 X148.082 Y134.633 E.43455
G3 X146.856 Y135.938 I-1.291 J.015 E.31596
G1 X132.111 Y135.94 E2.35428
G1 X132.099 Y135.658 E.04497
; WIPE_START
G1 X133.208 Y135.439 E-.42962
G1 X134.072 Y135.344 E-.33038
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.302 Y128.429 Z17.04 F42000
G1 X140.713 Y121.127 Z17.04
G1 Z16.64
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X140.76 Y120.76 E.05906
G1 X146.824 Y120.761 E.96826
G1 X147.022 Y120.807 E.03242
G1 X147.198 Y120.923 E.03367
G1 X147.333 Y121.115 E.03741
G1 X147.381 Y121.315 E.03297
G3 X147.383 Y123.14 I-32.88 J.943 E.29138
G1 X142.284 Y121.564 E.85212
G2 X140.83 Y121.156 I-7.959 J25.531 E.24121
; WIPE_START
G1 X140.76 Y120.76 E-.15275
G1 X142.358 Y120.76 E-.60725
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.732 Y120.447 Z17.04 F42000
G1 X132.085 Y120.339 Z17.04
G1 Z16.64
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X132.098 Y120.06 E.04457
G1 X146.862 Y120.062 E2.35753
G3 X148.082 Y121.366 I-.076 J1.294 E.31458
G1 X148.082 Y124.089 E.4347
G1 X142.083 Y122.235 E1.00262
G2 X134.428 Y120.694 I-12.671 J43.171 E1.24849
G2 X132.08 Y120.461 I-6.955 J58.198 E.37673
G1 X132.08 Y120.459 E.00041
; WIPE_START
G1 X132.098 Y120.06 E-.15168
G1 X133.698 Y120.06 E-.60832
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.076 Y120.454 Z17.04 F42000
G1 X123.576 Y120.584 Z17.04
G1 Z16.64
M73 P72 R5
G1 E.8 F1800
M106 S255
G1 F3215.099
M204 S6000
G1 X123.652 Y120.604 E.0125
G2 X124.73 Y120.76 I1.161 J-4.229 E.17435
G1 X130.847 Y120.76 E.97678
G1 X130.847 Y135.24 E2.31211
G1 X124.746 Y135.241 E.97409
G2 X122.772 Y135.744 I.029 J4.242 E.32859
G3 X118.147 Y118.818 I-4.959 J-7.74 E5.50075
G3 X122.769 Y120.256 I-.375 J9.358 E.7818
G2 X123.16 Y120.438 I2.043 J-3.88 E.0689
G1 X123.463 Y120.544 E.05123
M204 S10000
G1 X123.799 Y119.921 F42000
G1 F3215.099
M204 S6000
G1 X123.838 Y119.93 E.00637
G2 X124.745 Y120.06 I.967 J-3.522 E.14672
G1 X131.547 Y120.06 E1.0861
G1 X131.547 Y135.94 E2.53558
G1 X124.755 Y135.94 E1.08447
G2 X123.104 Y136.36 I.02 J3.538 E.27471
G3 X118.169 Y118.119 I-5.292 J-8.356 E5.91043
G3 X123.102 Y119.64 I-.395 J10.041 E.83365
G2 X123.425 Y119.79 I1.702 J-3.232 E.05683
G1 X123.685 Y119.882 E.0441
M204 S250
G1 X123.938 Y119.23 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.023 Y119.256 E.01427
G2 X124.76 Y119.36 I.773 J-2.817 E.1191
G1 X146.787 Y119.36 E3.51711
G3 X148.782 Y121.356 I.003 J1.992 E.50086
G1 X148.782 Y124.19 E.45238
G1 X148.782 Y124.59 E.06387
G1 F1500
G1 X148.782 Y125.353 E.12183
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X148.782 Y130.648 E.84554
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F1500
G1 X148.782 Y131.411 E.12183
M106 S196.35
G1 F3215.099
G1 X148.782 Y131.811 E.06387
G1 X148.782 Y134.644 E.45235
G3 X146.884 Y136.638 I-1.992 J.004 E.48533
G1 X124.764 Y136.64 E3.53206
G2 X123.436 Y136.976 I.011 J2.834 E.22082
G3 X118.191 Y117.419 I-5.625 J-8.973 E6.32015
G3 X123.436 Y119.024 I-.415 J10.727 E.88551
G2 X123.689 Y119.143 I1.361 J-2.584 E.04475
G1 X123.825 Y119.19 E.02291
; WIPE_START
M204 S6000
G1 X124.023 Y119.256 E-.07954
G1 X124.359 Y119.33 E-.13071
G1 X124.76 Y119.36 E-.15266
G1 X125.805 Y119.36 E-.39708
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


G1 X135.664 Y120.455 F42000
G1 Z16.64
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.240963
G1 F3000
M204 S6000
G1 X135.971 Y120.479 E.00851
; LINE_WIDTH: 0.285734
G1 X136.279 Y120.502 E.01166
; LINE_WIDTH: 0.330506
G1 X136.587 Y120.525 E.01481
; LINE_WIDTH: 0.375278
G1 X136.895 Y120.549 E.01797
; LINE_WIDTH: 0.418308
G1 X137.131 Y120.569 E.01616
; LINE_WIDTH: 0.459367
G1 X137.365 Y120.59 E.01813
; LINE_WIDTH: 0.500147
G1 X137.598 Y120.61 E.02031
; LINE_WIDTH: 0.540927
G1 X137.832 Y120.631 E.02249
; LINE_WIDTH: 0.581707
G1 X138.065 Y120.651 E.02467
; LINE_WIDTH: 0.625204
G1 X138.298 Y120.674 E.02693
; LINE_WIDTH: 0.670974
G1 X138.524 Y120.697 E.02863
; LINE_WIDTH: 0.716159
G1 X138.751 Y120.719 E.03098
; LINE_WIDTH: 0.761344
G1 X138.978 Y120.742 E.03333
; LINE_WIDTH: 0.806529
G1 X139.204 Y120.764 E.03568
; LINE_WIDTH: 0.8513
G1 X139.508 Y120.799 E.05091
; LINE_WIDTH: 0.893707
G1 F2908.743
G1 X139.802 Y120.832 E.05222
; LINE_WIDTH: 0.935447
G1 F2759.821
G1 X140.096 Y120.865 E.05503
; LINE_WIDTH: 0.977187
G1 F2625.406
G1 X140.39 Y120.898 E.05785
; WIPE_START
G1 X140.096 Y120.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.271 Y121.152 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.243686
G1 F3000
M204 S6000
G1 X142.463 Y121.181 E.00547
; LINE_WIDTH: 0.292344
G1 X142.655 Y121.21 E.00763
; LINE_WIDTH: 0.341003
G1 X142.847 Y121.239 E.00979
; LINE_WIDTH: 0.389661
G1 X143.039 Y121.268 E.01195
; LINE_WIDTH: 0.438319
G1 X143.231 Y121.297 E.0141
; LINE_WIDTH: 0.486978
G1 X143.423 Y121.326 E.01626
; LINE_WIDTH: 0.535636
G1 X143.615 Y121.355 E.01842
; LINE_WIDTH: 0.584294
G1 X143.808 Y121.383 E.02057
; LINE_WIDTH: 0.632952
G1 X144 Y121.412 E.02273
; LINE_WIDTH: 0.681611
G1 X144.192 Y121.441 E.02489
; LINE_WIDTH: 0.730269
G1 X144.384 Y121.47 E.02704
; LINE_WIDTH: 0.778927
G1 X144.576 Y121.499 E.0292
; LINE_WIDTH: 0.827586
G1 X144.768 Y121.528 E.03136
; LINE_WIDTH: 0.876244
G1 F2975.927
G1 X144.96 Y121.557 E.03351
; LINE_WIDTH: 0.924902
G1 F2795.986
G1 X145.152 Y121.586 E.03567
M204 S10000
G1 X145.787 Y121.935 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.779997
G1 F3410.021
M204 S6000
G1 X146.703 Y122.218 E.14428
G1 X146.703 Y121.441 E.11699
G1 X145.862 Y121.441 E.12664
G1 X145.805 Y121.817 E.0572
; WIPE_START
G1 X145.862 Y121.441 E-.14437
G1 X146.703 Y121.441 E-.31964
G1 X146.703 Y122.218 E-.29529
G1 X146.701 Y122.218 E-.0007
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z17.04 I-1.213 J-.093 P1  F42000
G1 X145.795 Y134.063 Z17.04
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.779587
G1 F3412.141
M204 S6000
G1 X145.869 Y134.559 E.07547
G1 X146.698 Y134.559 E.12466
G2 X146.703 Y133.782 I-24.807 J-.553 E.11686
G1 X145.909 Y134.027 E.12501
M204 S10000
G1 X145.16 Y134.412 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.92495
G1 F2795.818
M204 S6000
G1 X144.968 Y134.441 E.03568
; LINE_WIDTH: 0.876281
G1 F2975.78
G1 X144.776 Y134.47 E.03352
; LINE_WIDTH: 0.827613
G1 F3000
G1 X144.584 Y134.499 E.03136
; LINE_WIDTH: 0.778944
G1 X144.391 Y134.528 E.02921
; LINE_WIDTH: 0.730275
G1 X144.199 Y134.557 E.02705
; LINE_WIDTH: 0.681606
G1 X144.007 Y134.586 E.02489
; LINE_WIDTH: 0.632937
G1 X143.815 Y134.615 E.02273
; LINE_WIDTH: 0.584268
G1 X143.623 Y134.644 E.02058
; LINE_WIDTH: 0.535599
G1 X143.431 Y134.673 E.01842
; LINE_WIDTH: 0.48693
G1 X143.238 Y134.702 E.01626
; LINE_WIDTH: 0.438261
G1 X143.046 Y134.731 E.0141
; LINE_WIDTH: 0.389592
G1 X142.854 Y134.76 E.01195
; LINE_WIDTH: 0.340923
G1 X142.662 Y134.789 E.00979
; LINE_WIDTH: 0.292254
G1 X142.47 Y134.818 E.00763
; LINE_WIDTH: 0.243585
G1 X142.278 Y134.847 E.00547
; WIPE_START
G1 X142.47 Y134.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.399 Y135.102 Z17.04 F42000
G1 Z16.64
G1 E.8 F1800
; LINE_WIDTH: 0.973425
G1 F2636.983
M204 S6000
G1 X140.071 Y135.138 E.06427
; LINE_WIDTH: 0.924737
G1 F2796.561
G1 X139.743 Y135.175 E.0606
; LINE_WIDTH: 0.876048
G1 F2976.697
G1 X139.415 Y135.211 E.05693
; LINE_WIDTH: 0.82736
G1 F3000
G1 X139.087 Y135.248 E.05327
; LINE_WIDTH: 0.802099
G1 X139.078 Y135.248 E.00135
; LINE_WIDTH: 0.779215
G1 X138.854 Y135.27 E.0338
; LINE_WIDTH: 0.735228
G1 X138.631 Y135.292 E.03155
; LINE_WIDTH: 0.691241
G1 X138.407 Y135.314 E.02929
; LINE_WIDTH: 0.647254
G1 X138.183 Y135.336 E.02703
; LINE_WIDTH: 0.60273
G1 X137.954 Y135.359 E.02535
; LINE_WIDTH: 0.555621
G1 X137.669 Y135.384 E.02846
; LINE_WIDTH: 0.506339
G1 X137.383 Y135.408 E.02524
; LINE_WIDTH: 0.457057
G1 X137.098 Y135.433 E.02202
; LINE_WIDTH: 0.40752
G1 X136.809 Y135.458 E.01898
; LINE_WIDTH: 0.362149
G1 X136.524 Y135.479 E.01582
; LINE_WIDTH: 0.321127
G1 X136.238 Y135.501 E.01314
; LINE_WIDTH: 0.280104
G1 X135.952 Y135.522 E.01045
; LINE_WIDTH: 0.239082
G1 X135.667 Y135.544 E.00777
; WIPE_START
G1 X135.952 Y135.522 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.327 Y135.201 Z17.04 F42000
G1 X112.21 Y134.52 Z17.04
G1 Z16.64
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I6.002 J-6.849 E.44674
G1 X122.192 Y120.612 E2.65849
G2 X119.604 Y119.604 I-4.819 J8.548 E.44503
G1 X130.252 Y130.252 E2.40453
G1 X130.252 Y125.748 E.71921
G1 X119.603 Y136.397 E2.40468
G2 X122.193 Y135.389 I-1.961 J-8.874 E.44552
G1 X110.423 Y123.619 E2.65791
G3 X112.212 Y121.484 I8.398 J5.22 E.44624
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 17.2
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.5722
G1 X110.875 Y122.964 E-.1878
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 31/51
; update layer progress
M73 L31
M991 S0 P30 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z17.2 I-.832 J1.487 P1  F42000
G1 X131.729 Y134.636 Z17.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.729 Y120.568 E2.24641
G1 X133.906 Y120.85 E.35063
G3 X140.36 Y122.235 I-5.685 J42.232 E1.05491
G1 X147.454 Y124.427 E1.18569
G1 X147.454 Y124.712 E.04545
G1 F1500
G1 X147.454 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
M73 P73 R5
G1 F1800
M204 S5000
G1 X147.454 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X147.454 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X147.454 Y131.573 E.04545
G1 X140.361 Y133.765 E1.18547
G3 X138.287 Y134.33 I-13.103 J-44.001 E.34321
G3 X131.729 Y135.433 I-12.891 J-56.635 E1.0625
G1 X131.729 Y134.756 E.10801
M204 S250
G1 X132.429 Y134.636 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.429 Y121.364 E2.11922
G1 X133.024 Y121.441 E.0958
G1 X133.213 Y121.466 E.03056
G1 X133.808 Y121.543 E.0958
G1 X134.973 Y121.721 E.18806
G1 F3000
G1 X136.1 Y121.919 E.18271
G1 F2700
G1 X137.186 Y122.137 E.17688
G1 F2400
G1 X138.227 Y122.375 E.17054
G1 F1950
G1 X139.22 Y122.632 E.16383
G1 F1650
G1 X140.159 Y122.905 E.1561
G1 F1380
G1 X142.548 Y123.644 E.39936
M106 S196.35
M106 S255
G1 F1260
G1 X146.181 Y124.766 E.60712
M106 S196.35
M106 S255
G1 F1140
G1 X146.754 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X146.754 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X146.754 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X146.754 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X146.372 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X144.365 Y131.796 E.33547
M106 S196.35
M106 S255
G1 F1260
G1 X140.732 Y132.918 E.60707
M106 S196.35
M106 S255
G1 F1380
G1 X140.159 Y133.095 E.0958
M106 S196.35
G1 F1650
G1 X139.338 Y133.335 E.13656
G1 F1800
G1 X139.105 Y133.4 E.03873
G1 F1950
G1 X138.436 Y133.572 E.1102
G1 F2250
G1 X138.125 Y133.649 E.05117
G1 F2400
G1 X137.102 Y133.881 E.16749
G1 F2700
G1 X136.035 Y134.094 E.17378
G1 F3000
G1 X134.93 Y134.287 E.17915
G1 F3215.099
G1 X133.789 Y134.46 E.18423
G1 X133.194 Y134.537 E.09581
G1 X133.024 Y134.559 E.02742
G1 X132.548 Y134.621 E.07664
; WIPE_START
M204 S6000
G1 X132.53 Y132.621 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.001 Y134.872 Z17.6 F42000
G1 Z17.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G2 X140.563 Y134.435 I-7.366 J-29.372 E.259
G1 X147.383 Y132.328 E1.13981
G1 X147.383 Y134.623 E.36644
G3 X146.827 Y135.238 I-.593 J.023 E.14659
G1 X139.047 Y135.239 E1.24222
G1 X139.016 Y134.991 E.03992
; WIPE_START
G1 X140.563 Y134.435 E-.62459
G1 X140.903 Y134.33 E-.13541
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z17.6 I1.204 J-.174 P1  F42000
G1 X138.99 Y121.127 Z17.6
G1 Z17.2
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X139.037 Y120.76 E.05906
G1 X146.824 Y120.761 E1.24344
G1 X147.021 Y120.807 E.03237
G1 X147.175 Y120.901 E.02871
G1 X147.301 Y121.053 E.03152
G1 X147.371 Y121.236 E.03129
G1 X147.383 Y123.673 E.38908
G1 X140.56 Y121.564 E1.14019
G2 X139.106 Y121.156 I-7.95 J25.498 E.24117
; WIPE_START
G1 X139.037 Y120.76 E-.15275
G1 X140.635 Y120.76 E-.60725
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.003 Y120.681 Z17.6 F42000
G1 X123.577 Y120.584 Z17.6
G1 Z17.2
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X123.652 Y120.604 E.01246
G2 X124.729 Y120.76 I1.16 J-4.228 E.17424
G1 X131.029 Y120.76 E1.00586
G1 X131.029 Y135.24 E2.3121
G1 X124.747 Y135.241 E1.00314
G2 X122.771 Y135.744 I.029 J4.242 E.32869
G3 X118.157 Y118.818 I-4.953 J-7.741 E5.49944
G3 X122.768 Y120.255 I-.385 J9.357 E.78008
G2 X123.159 Y120.437 I2.044 J-3.879 E.06888
G1 X123.464 Y120.544 E.05155
M204 S10000
G1 X123.799 Y119.922 F42000
G1 F3215.099
M204 S6000
G1 X123.838 Y119.93 E.00633
G2 X124.745 Y120.06 I.966 J-3.522 E.14663
G1 X146.777 Y120.06 E3.51801
G3 X148.082 Y121.366 I.013 J1.293 E.32844
G1 X148.082 Y124.506 E.50133
G1 X148.082 Y124.906 E.06387
G1 F2250
G1 X148.082 Y131.095 E.98818
G1 F3215.099
G1 X148.082 Y131.495 E.06387
G1 X148.082 Y134.633 E.50119
G3 X146.855 Y135.938 I-1.291 J.015 E.31612
G1 X124.755 Y135.94 E3.52876
G2 X123.104 Y136.36 I.02 J3.538 E.27479
G3 X118.179 Y118.119 I-5.286 J-8.358 E5.90895
G3 X123.102 Y119.639 I-.405 J10.041 E.83199
G2 X123.424 Y119.79 I1.702 J-3.231 E.05677
G1 X123.686 Y119.882 E.04441
M204 S250
G1 X123.991 Y119.249 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.024 Y119.256 E.00539
G2 X124.76 Y119.36 I.772 J-2.816 E.11903
G1 X146.787 Y119.36 E3.51713
G3 X148.782 Y121.356 I.003 J1.992 E.50084
G1 X148.782 Y134.644 E2.12168
G3 X146.883 Y136.638 I-1.992 J.004 E.48551
G1 X124.764 Y136.64 E3.53189
G2 X123.436 Y136.976 I.011 J2.834 E.22089
G3 X112.256 Y118.985 I-5.622 J-8.975 E5.32502
G3 X118.201 Y117.419 I5.603 J9.205 E.99539
G3 X123.435 Y119.024 I-.425 J10.726 E.88392
G2 X123.688 Y119.142 I1.361 J-2.583 E.04466
G1 X123.878 Y119.209 E.03205
; WIPE_START
M204 S6000
G1 X124.024 Y119.256 E-.05837
G1 X124.361 Y119.331 E-.13113
G1 X124.76 Y119.36 E-.15208
G1 X125.861 Y119.36 E-.41843
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


G1 X133.939 Y120.455 F42000
G1 Z17.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.240798
G1 F3000
M204 S6000
G1 X134.245 Y120.479 E.00844
; LINE_WIDTH: 0.285239
G1 X134.551 Y120.502 E.01155
; LINE_WIDTH: 0.32968
G1 X134.857 Y120.525 E.01466
; LINE_WIDTH: 0.374121
G1 X135.163 Y120.548 E.01778
; LINE_WIDTH: 0.416997
G1 X135.4 Y120.569 E.01612
; LINE_WIDTH: 0.458108
G1 X135.634 Y120.589 E.01811
; LINE_WIDTH: 0.498942
G1 X135.868 Y120.61 E.0203
; LINE_WIDTH: 0.539776
G1 X136.102 Y120.63 E.02248
; LINE_WIDTH: 0.58061
M73 P73 R4
G1 X136.336 Y120.65 E.02467
; LINE_WIDTH: 0.624143
G1 X136.569 Y120.674 E.02689
; LINE_WIDTH: 0.66991
G1 X136.795 Y120.696 E.02859
; LINE_WIDTH: 0.715092
G1 X137.022 Y120.719 E.03094
; LINE_WIDTH: 0.760274
G1 X137.249 Y120.741 E.03329
; LINE_WIDTH: 0.805456
G1 X137.476 Y120.764 E.03564
; LINE_WIDTH: 0.850355
G1 X137.78 Y120.798 E.05105
; LINE_WIDTH: 0.893032
G1 F2911.283
G1 X138.076 Y120.832 E.0524
; LINE_WIDTH: 0.935042
G1 F2761.193
G1 X138.371 Y120.865 E.05525
; LINE_WIDTH: 0.977052
G1 F2625.82
G1 X138.666 Y120.898 E.05809
; WIPE_START
G1 X138.371 Y120.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.547 Y121.152 Z17.6 F42000
G1 Z17.2
G1 E.8 F1800
; LINE_WIDTH: 0.243686
G1 F3000
M204 S6000
G1 X140.739 Y121.181 E.00547
; LINE_WIDTH: 0.292343
G1 X140.931 Y121.21 E.00763
; LINE_WIDTH: 0.341001
G1 X141.124 Y121.239 E.00979
; LINE_WIDTH: 0.389659
G1 X141.316 Y121.268 E.01195
; LINE_WIDTH: 0.438316
G1 X141.508 Y121.297 E.0141
; LINE_WIDTH: 0.486974
G1 X141.7 Y121.326 E.01626
; LINE_WIDTH: 0.535632
G1 X141.892 Y121.355 E.01842
; LINE_WIDTH: 0.584289
G1 X142.084 Y121.383 E.02057
; LINE_WIDTH: 0.632947
G1 X142.276 Y121.412 E.02273
; LINE_WIDTH: 0.681605
G1 X142.468 Y121.441 E.02489
; LINE_WIDTH: 0.730262
G1 X142.66 Y121.47 E.02704
; LINE_WIDTH: 0.77892
G1 X142.852 Y121.499 E.0292
; LINE_WIDTH: 0.827578
G1 X143.045 Y121.528 E.03136
; LINE_WIDTH: 0.876235
G1 F2975.962
G1 X143.237 Y121.557 E.03351
; LINE_WIDTH: 0.924893
G1 F2796.018
G1 X143.429 Y121.586 E.03567
M204 S10000
G1 X144.189 Y121.856 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.00504
G1 F2542.775
M204 S6000
G1 X146.585 Y122.597 E.50625
G1 X146.58 Y121.554 E.21058
G1 X144.235 Y121.553 E.47344
G1 X144.207 Y121.738 E.03767
; WIPE_START
G1 X144.235 Y121.553 E-.07091
G1 X146.048 Y121.554 E-.68909
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z17.6 I-1.204 J-.177 P1  F42000
G1 X144.197 Y134.142 Z17.6
G1 Z17.2
G1 E.8 F1800
; LINE_WIDTH: 1.00572
G1 F2540.823
M204 S6000
G1 X144.242 Y134.446 E.06203
G1 X146.59 Y134.446 E.47434
G1 X146.59 Y133.403 E.21073
G1 X144.311 Y134.107 E.4819
M204 S10000
M73 P74 R4
G1 X143.436 Y134.412 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.924968
G1 F2795.758
M204 S6000
G1 X143.243 Y134.441 E.03568
; LINE_WIDTH: 0.8763
G1 F2975.706
G1 X143.051 Y134.47 E.03352
; LINE_WIDTH: 0.827633
G1 F3000
G1 X142.859 Y134.499 E.03137
; LINE_WIDTH: 0.778965
G1 X142.667 Y134.528 E.02921
; LINE_WIDTH: 0.730297
G1 X142.475 Y134.557 E.02705
; LINE_WIDTH: 0.68163
G1 X142.283 Y134.586 E.02489
; LINE_WIDTH: 0.632962
G1 X142.091 Y134.615 E.02274
; LINE_WIDTH: 0.584294
G1 X141.898 Y134.644 E.02058
; LINE_WIDTH: 0.535627
G1 X141.706 Y134.673 E.01842
; LINE_WIDTH: 0.486959
G1 X141.514 Y134.702 E.01626
; LINE_WIDTH: 0.438292
G1 X141.322 Y134.731 E.0141
; LINE_WIDTH: 0.389624
G1 X141.13 Y134.76 E.01195
; LINE_WIDTH: 0.340956
G1 X140.938 Y134.789 E.00979
; LINE_WIDTH: 0.292289
G1 X140.745 Y134.818 E.00763
; LINE_WIDTH: 0.243621
G1 X140.553 Y134.847 E.00547
; WIPE_START
G1 X140.745 Y134.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.677 Y135.101 Z17.6 F42000
G1 Z17.2
G1 E.8 F1800
; LINE_WIDTH: 0.97489
G1 F2632.464
M204 S6000
G1 X138.357 Y135.137 E.0628
; LINE_WIDTH: 0.927818
G1 F2785.891
G1 X138.037 Y135.173 E.05934
; LINE_WIDTH: 0.880747
G1 F2958.308
G1 X137.717 Y135.208 E.05588
; LINE_WIDTH: 0.833024
G1 F3000
G1 X137.388 Y135.245 E.05381
; LINE_WIDTH: 0.786307
G1 X137.165 Y135.267 E.03404
; LINE_WIDTH: 0.742302
G1 X136.942 Y135.289 E.03179
; LINE_WIDTH: 0.698296
G1 X136.719 Y135.311 E.02954
; LINE_WIDTH: 0.654291
G1 X136.496 Y135.333 E.0273
; LINE_WIDTH: 0.609736
G1 X136.268 Y135.356 E.02564
; LINE_WIDTH: 0.56242
G1 X135.981 Y135.381 E.02902
; LINE_WIDTH: 0.512753
G1 X135.695 Y135.405 E.02576
; LINE_WIDTH: 0.463087
G1 X135.408 Y135.43 E.0225
; LINE_WIDTH: 0.41342
G1 X135.122 Y135.455 E.01924
; LINE_WIDTH: 0.388353
G1 X135.119 Y135.455 E.00019
; LINE_WIDTH: 0.366911
G1 X134.825 Y135.478 E.01658
; LINE_WIDTH: 0.324528
G1 X134.532 Y135.5 E.01373
; LINE_WIDTH: 0.282144
G1 X134.238 Y135.522 E.01088
; LINE_WIDTH: 0.239761
G1 X133.944 Y135.544 E.00803
; WIPE_START
G1 X134.238 Y135.522 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.802 Y131.42 Z17.6 F42000
G1 X112.212 Y121.484 Z17.6
G1 Z17.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.423 Y123.619 I6.609 J7.355 E.44623
G1 X122.193 Y135.389 E2.65788
G3 X119.603 Y136.397 I-4.543 J-7.848 E.44549
G1 X130.434 Y125.566 E2.44572
G1 X130.434 Y130.434 E.77732
G1 X119.604 Y119.604 E2.44558
G3 X122.192 Y120.612 I-2.234 J9.564 E.44499
G1 X110.42 Y132.384 E2.65841
G2 X112.21 Y134.52 I7.79 J-4.71 E.44673
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 17.76
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.528 Y133.868 E-.35861
G1 X111.029 Y133.283 E-.29187
G1 X110.868 Y133.045 E-.10952
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 32/51
; update layer progress
M73 L32
M991 S0 P31 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z17.76 I-.108 J1.7 P1  F42000
G1 X131.911 Y134.378 Z17.76
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.911 Y120.809 E2.16657
G3 X138.636 Y122.235 I-5.858 J44.21 E1.09888
G1 X145.731 Y124.427 E1.18564
G1 X145.731 Y124.712 E.04545
G1 F1500
G1 X145.731 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X145.731 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X145.731 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X145.731 Y131.573 E.04545
G1 X138.636 Y133.766 E1.18574
G3 X131.911 Y135.193 I-12.66 J-43.11 E1.0988
G1 X131.911 Y134.498 E.11099
M204 S250
G1 X132.61 Y134.378 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.61 Y121.623 E2.03654
G1 X133.242 Y121.719 E.10192
G1 F3000
G1 X134.37 Y121.918 E.18298
G1 F2700
G1 X135.458 Y122.136 E.17714
G1 F2400
G1 X136.5 Y122.374 E.17073
G1 F1950
G1 X137.495 Y122.631 E.16412
G1 F1650
G1 X138.436 Y122.905 E.15637
G1 F1380
G1 X140.825 Y123.644 E.39934
M106 S196.35
M106 S255
G1 F1260
G1 X144.458 Y124.766 E.60708
M106 S196.35
M106 S255
G1 F1140
G1 X145.031 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X145.031 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X145.031 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X145.031 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X144.649 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X141.733 Y132.076 E.48729
M106 S196.35
M106 S255
G1 F1260
G1 X139.008 Y132.918 E.45535
M106 S196.35
M106 S255
G1 F1380
G1 X138.435 Y133.095 E.0958
M106 S196.35
G1 F1650
G1 X137.416 Y133.39 E.16935
G1 F1950
G1 X136.436 Y133.641 E.16154
G1 F2400
G1 X135.412 Y133.874 E.16775
G1 F2700
G1 X134.344 Y134.088 E.17388
G1 F3000
G1 X133.249 Y134.28 E.1776
G1 F3215.099
G1 X132.729 Y134.359 E.08391
; WIPE_START
M204 S6000
G1 X132.71 Y132.36 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.579 Y125.287 Z18.16 F42000
G1 X137.266 Y121.127 Z18.16
G1 Z17.76
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X137.313 Y120.76 E.05907
G1 X146.824 Y120.761 E1.51863
G1 X147.022 Y120.807 E.03238
G1 X147.198 Y120.923 E.03373
G1 X147.333 Y121.115 E.03746
G1 X147.381 Y121.315 E.03289
G1 X147.383 Y134.623 E2.1249
G3 X146.826 Y135.238 I-.593 J.024 E.14678
G1 X137.319 Y135.239 E1.518
G1 X137.273 Y134.872 E.05913
G2 X138.836 Y134.436 I-6.239 J-25.422 E.25922
G1 X146.431 Y132.09 E1.26918
G1 X146.431 Y131.472 E.09854
G1 X146.431 Y131.072 E.06387
G1 F2550
G1 X146.431 Y124.928 E.98112
G1 F3215.099
G1 X146.431 Y124.528 E.06387
G1 X146.431 Y123.911 E.09854
G1 X138.837 Y121.564 E1.26905
G2 X137.383 Y121.156 I-7.929 J25.422 E.24123
; WIPE_START
G1 X137.313 Y120.76 E-.15275
G1 X138.911 Y120.76 E-.60725
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.279 Y120.673 Z18.16 F42000
G1 X123.578 Y120.584 Z18.16
G1 Z17.76
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X123.653 Y120.605 E.01242
G2 X124.729 Y120.76 I1.159 J-4.227 E.17411
G1 X131.211 Y120.76 E1.03494
G1 X131.211 Y135.24 E2.3121
G1 X124.747 Y135.241 E1.03218
G2 X122.771 Y135.744 I.029 J4.242 E.32873
G3 X118.167 Y118.819 I-4.957 J-7.74 E5.50338
G3 X122.768 Y120.255 I-.396 J9.357 E.77844
G2 X123.158 Y120.436 I2.044 J-3.877 E.06865
G1 X123.465 Y120.544 E.05194
M204 S10000
G1 X123.8 Y119.922 F42000
G1 F3215.099
M204 S6000
G1 X123.838 Y119.931 E.00626
G2 X124.745 Y120.06 I.965 J-3.52 E.14654
G1 X146.777 Y120.06 E3.51802
G3 X148.082 Y121.366 I.013 J1.293 E.32843
G1 X148.082 Y134.633 E2.11844
G3 X146.854 Y135.938 I-1.295 J.011 E.31603
G1 X124.755 Y135.94 E3.52861
G2 X123.103 Y136.36 I.02 J3.537 E.27483
G3 X118.189 Y118.119 I-5.29 J-8.357 E5.91308
G3 X123.102 Y119.639 I-.416 J10.041 E.83032
G2 X123.422 Y119.789 I1.702 J-3.229 E.05654
G1 X123.687 Y119.882 E.04479
M204 S250
G1 X124.054 Y119.266 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.363 Y119.328 E.05033
G2 X124.76 Y119.36 I.433 J-2.886 E.06367
G1 X146.787 Y119.36 E3.51715
G3 X148.782 Y121.356 I.003 J1.992 E.50084
G1 X148.782 Y134.644 E2.12168
G3 X146.882 Y136.638 I-1.996 J0 E.48542
G1 X124.764 Y136.64 E3.53173
G2 X123.436 Y136.976 I.011 J2.834 E.22092
G3 X118.212 Y117.42 I-5.623 J-8.974 E6.3228
G3 X123.435 Y119.024 I-.436 J10.726 E.88221
G2 X123.939 Y119.232 I1.361 J-2.582 E.08713
; WIPE_START
M204 S6000
G1 X124.363 Y119.328 E-.16521
G1 X124.76 Y119.36 E-.15142
G1 X125.927 Y119.36 E-.44337
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


G1 X132.216 Y120.455 F42000
G1 Z17.76
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.24064
G1 F3000
M204 S6000
G1 X132.52 Y120.478 E.00838
; LINE_WIDTH: 0.284767
G1 X132.824 Y120.501 E.01145
; LINE_WIDTH: 0.328893
G1 X133.128 Y120.524 E.01452
; LINE_WIDTH: 0.37302
G1 X133.432 Y120.547 E.01759
; LINE_WIDTH: 0.415749
G1 X133.669 Y120.568 E.01607
; LINE_WIDTH: 0.456881
G1 X133.903 Y120.589 E.01807
; LINE_WIDTH: 0.497736
G1 X134.138 Y120.609 E.02026
; LINE_WIDTH: 0.538592
G1 X134.372 Y120.629 E.02245
; LINE_WIDTH: 0.579448
G1 X134.606 Y120.65 E.02464
; LINE_WIDTH: 0.623011
G1 X134.839 Y120.673 E.02687
; LINE_WIDTH: 0.66883
G1 X135.067 Y120.696 E.02858
; LINE_WIDTH: 0.714065
G1 X135.294 Y120.718 E.03094
; LINE_WIDTH: 0.7593
G1 X135.521 Y120.741 E.0333
; LINE_WIDTH: 0.804535
G1 X135.748 Y120.763 E.03565
; LINE_WIDTH: 0.849566
G1 X136.054 Y120.798 E.05117
; LINE_WIDTH: 0.892469
G1 F2913.407
G1 X136.35 Y120.831 E.05255
; LINE_WIDTH: 0.934703
G1 F2762.342
G1 X136.646 Y120.865 E.05542
; LINE_WIDTH: 0.976938
G1 F2626.17
G1 X136.943 Y120.898 E.05829
; WIPE_START
G1 X136.646 Y120.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.824 Y121.152 Z18.16 F42000
G1 Z17.76
G1 E.8 F1800
; LINE_WIDTH: 0.243686
G1 F3000
M204 S6000
G1 X139.016 Y121.181 E.00547
; LINE_WIDTH: 0.292344
G1 X139.208 Y121.21 E.00763
; LINE_WIDTH: 0.341001
G1 X139.4 Y121.239 E.00979
; LINE_WIDTH: 0.389659
G1 X139.592 Y121.268 E.01195
; LINE_WIDTH: 0.438317
G1 X139.784 Y121.297 E.0141
; LINE_WIDTH: 0.486975
G1 X139.976 Y121.326 E.01626
; LINE_WIDTH: 0.535632
G1 X140.168 Y121.355 E.01842
; LINE_WIDTH: 0.58429
G1 X140.361 Y121.383 E.02057
; LINE_WIDTH: 0.632948
G1 X140.553 Y121.412 E.02273
; LINE_WIDTH: 0.681606
G1 X140.745 Y121.441 E.02489
; LINE_WIDTH: 0.730264
G1 X140.937 Y121.47 E.02704
; LINE_WIDTH: 0.778921
M73 P75 R4
G1 X141.129 Y121.499 E.0292
; LINE_WIDTH: 0.827579
G1 X141.321 Y121.528 E.03136
; LINE_WIDTH: 0.876237
G1 F2975.955
G1 X141.513 Y121.557 E.03351
; LINE_WIDTH: 0.924895
G1 F2796.012
G1 X141.705 Y121.586 E.03567
M204 S10000
G1 X142.363 Y121.921 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X146.192 Y123.105 E.64006
G1 X146.262 Y123.009 E.01884
G1 X146.681 Y122.992 E.06707
G1 X146.681 Y121.461 E.24443
G1 X142.432 Y121.461 E.67849
G1 X142.38 Y121.803 E.05525
M204 S10000
G1 X145.971 Y122.134 F42000
; LINE_WIDTH: 0.944157
G1 F2730.649
M204 S6000
G1 X145.868 Y122.134 E.01936
G1 X145.816 Y122.223 E.01936
G1 X145.868 Y122.312 E.01936
G1 X145.954 Y122.312 E.01616
M204 S10000
G1 X146.907 Y123.692 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.372487
G1 F3000
M204 S6000
G1 X146.907 Y132.309 E.49605
M204 S10000
G1 X142.369 Y134.077 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X142.438 Y134.539 E.07454
G1 X146.683 Y134.538 E.67776
G1 X146.683 Y133.008 E.2443
G1 X146.262 Y132.991 E.06725
G1 X146.192 Y132.896 E.01885
G1 X142.483 Y134.042 E.6199
M204 S10000
G1 X145.972 Y133.688 F42000
; LINE_WIDTH: 0.943797
G1 F2731.842
M204 S6000
G1 X145.87 Y133.688 E.01934
G1 X145.818 Y133.777 E.01935
G1 X145.87 Y133.866 E.01935
G1 X145.955 Y133.866 E.01614
M204 S10000
G1 X141.711 Y134.413 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.925008
G1 F2795.618
M204 S6000
G1 X141.519 Y134.442 E.03569
; LINE_WIDTH: 0.876347
G1 F2975.522
G1 X141.327 Y134.47 E.03353
; LINE_WIDTH: 0.827686
G1 F3000
G1 X141.135 Y134.499 E.03138
; LINE_WIDTH: 0.779025
G1 X140.943 Y134.528 E.02922
; LINE_WIDTH: 0.730364
G1 X140.75 Y134.557 E.02706
; LINE_WIDTH: 0.681703
G1 X140.558 Y134.586 E.0249
; LINE_WIDTH: 0.633042
G1 X140.366 Y134.615 E.02274
; LINE_WIDTH: 0.584381
G1 X140.174 Y134.644 E.02059
; LINE_WIDTH: 0.53572
G1 X139.982 Y134.673 E.01843
; LINE_WIDTH: 0.487059
G1 X139.789 Y134.702 E.01627
; LINE_WIDTH: 0.438398
G1 X139.597 Y134.731 E.01411
; LINE_WIDTH: 0.389737
G1 X139.405 Y134.76 E.01195
; LINE_WIDTH: 0.341076
G1 X139.213 Y134.789 E.0098
; LINE_WIDTH: 0.292415
G1 X139.021 Y134.818 E.00764
; LINE_WIDTH: 0.243754
G1 X138.829 Y134.847 E.00548
; WIPE_START
G1 X139.021 Y134.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.949 Y135.101 Z18.16 F42000
G1 Z17.76
G1 E.8 F1800
; LINE_WIDTH: 0.975375
G1 F2630.97
M204 S6000
G1 X136.639 Y135.136 E.0609
; LINE_WIDTH: 0.930318
G1 F2777.294
G1 X136.329 Y135.171 E.05769
; LINE_WIDTH: 0.885261
G1 F2940.852
G1 X136.018 Y135.206 E.05449
; LINE_WIDTH: 0.839551
G1 F3000
G1 X135.699 Y135.242 E.0527
; LINE_WIDTH: 0.793699
G1 X135.476 Y135.264 E.03443
; LINE_WIDTH: 0.749504
G1 X135.253 Y135.286 E.03217
; LINE_WIDTH: 0.705309
G1 X135.03 Y135.308 E.02992
; LINE_WIDTH: 0.661114
G1 X134.807 Y135.33 E.02765
; LINE_WIDTH: 0.616358
G1 X134.579 Y135.353 E.02601
; LINE_WIDTH: 0.569048
G1 X134.295 Y135.377 E.0292
; LINE_WIDTH: 0.519591
G1 X134.011 Y135.402 E.02599
; LINE_WIDTH: 0.470135
G1 X133.727 Y135.427 E.02277
; LINE_WIDTH: 0.420416
G1 X133.439 Y135.452 E.01974
; LINE_WIDTH: 0.373347
G1 X133.136 Y135.475 E.01756
; LINE_WIDTH: 0.329124
G1 X132.833 Y135.498 E.01449
; LINE_WIDTH: 0.2849
G1 X132.53 Y135.521 E.01142
; LINE_WIDTH: 0.240676
G1 X132.227 Y135.544 E.00836
; WIPE_START
G1 X132.53 Y135.521 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.907 Y135.146 Z18.16 F42000
G1 X112.21 Y134.52 Z18.16
G1 Z17.76
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.42 Y132.384 I6 J-6.845 E.44671
G1 X122.192 Y120.612 E2.65836
G2 X119.604 Y119.604 I-4.825 J8.565 E.44496
G1 X130.616 Y130.616 E2.48663
G1 X130.616 Y125.384 E.83542
G1 X119.604 Y136.396 E2.48676
G2 X122.193 Y135.389 I-1.944 J-8.833 E.44546
G1 X110.423 Y123.619 E2.65785
G3 X112.212 Y121.484 I8.4 J5.222 E.44622
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 18.32
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.156 Y122.557 E-.57213
G1 X110.875 Y122.964 E-.18787
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 33/51
; update layer progress
M73 L33
M991 S0 P32 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z18.32 I-.789 J1.51 P1  F42000
G1 X132.093 Y134.053 Z18.32
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.093 Y121.093 E2.06953
G3 X136.913 Y122.235 I-8.105 J44.939 E.79147
G1 X144.007 Y124.427 E1.18554
G1 X144.007 Y124.712 E.04545
G1 F1500
G1 X144.007 Y125.475 E.12183
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X144.007 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X144.007 Y131.289 E.12183
M106 S196.35
M106 S255
G1 F3215.099
G1 X144.007 Y131.573 E.04545
G1 X136.913 Y133.766 E1.18564
G3 X132.093 Y134.908 I-12.35 J-41.381 E.79141
G1 X132.093 Y134.173 E.11725
M204 S250
G1 X132.792 Y134.053 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.792 Y121.947 E1.93309
G1 F2700
G1 X133.73 Y122.135 E.15268
G1 F2400
G1 X134.774 Y122.374 E.17099
G1 F1950
G1 X135.771 Y122.631 E.16436
G1 F1650
G1 X136.712 Y122.905 E.15659
G1 F1380
G1 X139.102 Y123.644 E.39934
M106 S196.35
M106 S255
G1 F1260
G1 X142.734 Y124.766 E.60708
M106 S196.35
M106 S255
G1 F1140
G1 X143.307 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X143.307 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X143.307 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X143.307 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X142.925 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X140.918 Y131.796 E.33548
M106 S196.35
M106 S255
G1 F1260
G1 X137.285 Y132.918 E.60709
M106 S196.35
M106 S255
G1 F1380
G1 X136.712 Y133.095 E.0958
M106 S196.35
G1 F1650
G1 X135.816 Y133.357 E.14909
G1 F1950
G1 X134.746 Y133.633 E.17635
G1 F2400
G1 X133.721 Y133.867 E.16791
G1 F2700
G1 X132.91 Y134.03 E.13209
; WIPE_START
M204 S6000
G1 X132.891 Y132.03 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.695 Y124.614 Z18.72 F42000
G1 X135.543 Y121.127 Z18.72
G1 Z18.32
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X135.59 Y120.76 E.05907
G1 X146.824 Y120.761 E1.79381
G1 X147.022 Y120.807 E.03243
G1 X147.198 Y120.922 E.03368
G1 X147.333 Y121.114 E.03739
G1 X147.381 Y121.315 E.03298
G1 X147.383 Y134.623 E2.1249
G3 X146.825 Y135.238 I-.591 J.025 E.14703
G1 X135.591 Y135.239 E1.79377
G1 X135.544 Y134.873 E.05906
G2 X137.114 Y134.436 I-6.31 J-25.724 E.26014
G1 X144.707 Y132.09 E1.26903
G1 X144.707 Y131.472 E.09854
G1 X144.707 Y131.072 E.06387
G1 F2550
G1 X144.707 Y124.928 E.98112
G1 F3215.099
G1 X144.707 Y124.528 E.06387
G1 X144.707 Y123.911 E.09854
G1 X137.114 Y121.565 E1.26895
G2 X135.659 Y121.156 I-7.914 J25.368 E.24132
; WIPE_START
G1 X135.59 Y120.76 E-.15276
G1 X137.188 Y120.76 E-.60724
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.556 Y120.662 Z18.72 F42000
G1 X123.579 Y120.584 Z18.72
G1 Z18.32
G1 E.8 F1800
M73 P76 R4
G1 F3215.099
M204 S6000
G1 X123.654 Y120.605 E.01241
G2 X124.729 Y120.76 I1.158 J-4.226 E.17393
G1 X131.393 Y120.76 E1.06406
G1 X131.393 Y135.24 E2.3121
G1 X124.747 Y135.241 E1.06123
G2 X122.771 Y135.744 I.029 J4.242 E.32883
G3 X118.177 Y118.819 I-4.957 J-7.741 E5.505
G3 X122.768 Y120.255 I-.406 J9.356 E.77679
G2 X123.156 Y120.436 I2.044 J-3.876 E.06846
G1 X123.465 Y120.545 E.05235
M204 S10000
G1 X123.801 Y119.922 F42000
G1 F3215.099
M204 S6000
G1 X123.839 Y119.931 E.00623
G2 X124.744 Y120.06 I.964 J-3.52 E.14637
G1 X146.777 Y120.06 E3.51811
G3 X148.082 Y121.366 I.013 J1.293 E.32841
G1 X148.082 Y134.633 E2.11844
G3 X146.853 Y135.938 I-1.291 J.016 E.31647
G1 X124.755 Y135.94 E3.52846
G2 X123.103 Y136.36 I.02 J3.537 E.2749
G3 X118.199 Y118.119 I-5.29 J-8.357 E5.91468
G3 X123.101 Y119.639 I-.426 J10.04 E.82873
G2 X123.421 Y119.789 I1.702 J-3.228 E.05635
G1 X123.688 Y119.882 E.04516
M204 S250
G1 X124.112 Y119.278 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.364 Y119.328 E.04097
G2 X124.76 Y119.36 I.431 J-2.885 E.06344
G1 X146.787 Y119.36 E3.51717
G3 X148.782 Y121.356 I.003 J1.992 E.50083
G1 X148.782 Y134.644 E2.12168
G3 X146.881 Y136.638 I-1.991 J.005 E.48587
G1 X124.764 Y136.64 E3.53156
G2 X123.435 Y136.976 I.011 J2.833 E.22096
G3 X107.373 Y129.793 I-5.62 J-8.982 E3.3149
G3 X109.873 Y120.99 I10.432 J-1.794 E1.51102
G3 X118.221 Y117.42 I7.936 J7.012 E1.49824
G3 X123.435 Y119.024 I-.445 J10.726 E.88068
G2 X123.996 Y119.249 I1.361 J-2.581 E.09674
; WIPE_START
M204 S6000
G1 X124.364 Y119.328 E-.14305
G1 X124.76 Y119.36 E-.15085
G1 X125.986 Y119.36 E-.4661
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


G1 X131.743 Y120.536 F42000
G1 Z18.32
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.424537
G1 F3000
M204 S6000
G1 X131.996 Y120.562 E.01765
; LINE_WIDTH: 0.471777
G1 X132.249 Y120.587 E.02039
; LINE_WIDTH: 0.519017
G1 X132.502 Y120.612 E.02314
; LINE_WIDTH: 0.566257
G1 X132.755 Y120.637 E.02588
; LINE_WIDTH: 0.613497
G1 X133.008 Y120.662 E.02862
; LINE_WIDTH: 0.660738
G1 X133.261 Y120.687 E.03136
; LINE_WIDTH: 0.707978
G1 X133.514 Y120.713 E.0341
; LINE_WIDTH: 0.755218
G1 X133.767 Y120.738 E.03684
; LINE_WIDTH: 0.802458
G1 X134.02 Y120.763 E.03958
; LINE_WIDTH: 0.848619
G1 X134.326 Y120.797 E.05132
; LINE_WIDTH: 0.891791
G1 F2915.966
G1 X134.624 Y120.831 E.05272
; LINE_WIDTH: 0.934294
G1 F2763.732
G1 X134.922 Y120.865 E.05562
; LINE_WIDTH: 0.976796
G1 F2626.604
G1 X135.219 Y120.898 E.05853
; WIPE_START
G1 X134.922 Y120.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.1 Y121.152 Z18.72 F42000
G1 Z18.32
G1 E.8 F1800
; LINE_WIDTH: 0.243686
G1 F3000
M204 S6000
G1 X137.292 Y121.181 E.00547
; LINE_WIDTH: 0.292344
G1 X137.484 Y121.21 E.00763
; LINE_WIDTH: 0.341002
G1 X137.676 Y121.239 E.00979
; LINE_WIDTH: 0.38966
G1 X137.869 Y121.268 E.01195
; LINE_WIDTH: 0.438318
G1 X138.061 Y121.297 E.0141
; LINE_WIDTH: 0.486976
G1 X138.253 Y121.326 E.01626
; LINE_WIDTH: 0.535634
G1 X138.445 Y121.355 E.01842
; LINE_WIDTH: 0.584292
G1 X138.637 Y121.383 E.02057
; LINE_WIDTH: 0.63295
G1 X138.829 Y121.412 E.02273
; LINE_WIDTH: 0.681608
G1 X139.021 Y121.441 E.02489
; LINE_WIDTH: 0.730266
G1 X139.213 Y121.47 E.02704
; LINE_WIDTH: 0.778924
G1 X139.405 Y121.499 E.0292
; LINE_WIDTH: 0.827582
G1 X139.598 Y121.528 E.03136
; LINE_WIDTH: 0.87624
G1 F2975.941
G1 X139.79 Y121.557 E.03351
; LINE_WIDTH: 0.924898
G1 F2795.999
G1 X139.982 Y121.586 E.03567
; WIPE_START
G1 X139.79 Y121.557 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z18.72 I-1.162 J.361 P1  F42000
G1 X143.615 Y133.865 Z18.72
G1 Z18.32
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.768297
G1 F3471.579
M204 S6000
G1 X146.009 Y133.865 E.35394
G1 X146.009 Y132.602 E.18664
G1 X145.534 Y133.254 E.1192
G1 X145.359 Y133.326 E.02793
G1 X143.73 Y133.829 E.25218
; WIPE_START
G1 X145.359 Y133.326 E-.64802
G1 X145.534 Y133.254 E-.07177
G1 X145.596 Y133.168 E-.04022
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z18.72 I1.198 J-.215 P1  F42000
G1 X143.613 Y122.135 Z18.72
G1 Z18.32
G1 E.8 F1800
; LINE_WIDTH: 0.768337
G1 F3471.365
M204 S6000
G1 X145.359 Y122.675 E.27036
G1 X145.533 Y122.746 E.02775
G1 X146.007 Y123.531 E.13569
G1 X146.007 Y122.135 E.20648
G1 X143.733 Y122.135 E.3364
M204 S10000
G1 X140.639 Y121.921 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X145.16 Y123.318 E.75561
; LINE_WIDTH: 0.843946
G1 F3108.726
G1 X145.225 Y123.374 E.01414
; LINE_WIDTH: 0.891845
G1 F2915.764
G1 X145.29 Y123.43 E.01508
; LINE_WIDTH: 0.939743
G1 F2745.356
G1 X145.355 Y123.486 E.01602
; LINE_WIDTH: 0.987641
G1 F2593.767
G1 X145.42 Y123.541 E.01695
; LINE_WIDTH: 1.03554
G1 F2458.043
G1 X145.485 Y123.597 E.01789
; LINE_WIDTH: 1.10743
G1 F2279.061
G1 X145.551 Y123.653 E.01929
G1 X145.551 Y132.348 E1.95859
; LINE_WIDTH: 1.11168
G1 F2269.289
G1 X145.547 Y132.434 E.01946
; LINE_WIDTH: 1.0908
G1 F2318.102
G1 X145.483 Y132.475 E.01697
; LINE_WIDTH: 1.04156
M73 P77 R4
G1 F2441.976
G1 X145.418 Y132.516 E.01611
; LINE_WIDTH: 0.992325
G1 F2579.836
G1 X145.354 Y132.558 E.01525
; LINE_WIDTH: 0.943089
G1 F2734.194
G1 X145.289 Y132.599 E.01439
; LINE_WIDTH: 0.893852
G1 F2908.198
G1 X145.225 Y132.641 E.01353
; LINE_WIDTH: 0.820151
G1 F3214.405
G1 X145.16 Y132.682 E.01224
G1 X140.644 Y134.078 E.75488
G1 X140.714 Y134.539 E.07456
G1 X146.683 Y134.539 E.95329
G1 X146.683 Y133.54 E.1594
; LINE_WIDTH: 0.844615
G1 F3105.854
G1 X146.658 Y133.37 E.02842
; LINE_WIDTH: 0.893852
G1 F2908.198
G1 X146.633 Y133.2 E.03035
; LINE_WIDTH: 0.943089
G1 F2734.194
G1 X146.609 Y133.03 E.03228
; LINE_WIDTH: 0.992325
G1 F2579.836
G1 X146.584 Y132.86 E.03421
; LINE_WIDTH: 1.04156
G1 F2441.976
G1 X146.559 Y132.69 E.03615
; LINE_WIDTH: 1.10742
G1 F2279.08
G3 X146.539 Y132.348 I1.014 J-.234 E.07753
G1 X146.538 Y123.653 E1.95856
; LINE_WIDTH: 1.08344
G1 F2335.816
G1 X146.562 Y123.454 E.04404
; LINE_WIDTH: 1.03554
G1 F2458.043
G1 X146.586 Y123.255 E.04185
; LINE_WIDTH: 0.987641
G1 F2593.767
G1 X146.61 Y123.056 E.03966
; LINE_WIDTH: 0.939743
G1 F2745.356
G1 X146.633 Y122.857 E.03747
; LINE_WIDTH: 0.891845
G1 F2915.764
G1 X146.657 Y122.658 E.03528
; LINE_WIDTH: 0.820635
G1 F3212.182
G1 X146.681 Y122.459 E.03203
G1 X146.681 Y121.461 E.15947
G1 X140.708 Y121.46 E.95456
G1 X140.657 Y121.803 E.05532
; WIPE_START
G1 X140.708 Y121.46 E-.13153
G1 X142.362 Y121.461 E-.62847
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z18.72 I-1.197 J-.22 P1  F42000
G1 X139.987 Y134.413 Z18.72
G1 Z18.32
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.924963
G1 F2795.776
M204 S6000
G1 X139.795 Y134.442 E.03569
; LINE_WIDTH: 0.876298
G1 F2975.715
G1 X139.603 Y134.471 E.03353
; LINE_WIDTH: 0.827633
G1 F3000
G1 X139.411 Y134.5 E.03137
; LINE_WIDTH: 0.778968
G1 X139.219 Y134.529 E.02921
; LINE_WIDTH: 0.730303
G1 X139.026 Y134.558 E.02705
; LINE_WIDTH: 0.681638
G1 X138.834 Y134.587 E.0249
; LINE_WIDTH: 0.632974
G1 X138.642 Y134.616 E.02274
; LINE_WIDTH: 0.584309
G1 X138.45 Y134.644 E.02058
; LINE_WIDTH: 0.535644
G1 X138.258 Y134.673 E.01842
; LINE_WIDTH: 0.486979
G1 X138.066 Y134.702 E.01626
; LINE_WIDTH: 0.438314
G1 X137.873 Y134.731 E.01411
; LINE_WIDTH: 0.389649
G1 X137.681 Y134.76 E.01195
; LINE_WIDTH: 0.340985
G1 X137.489 Y134.789 E.00979
; LINE_WIDTH: 0.29232
G1 X137.297 Y134.818 E.00763
; LINE_WIDTH: 0.243655
G1 X137.105 Y134.847 E.00547
; WIPE_START
G1 X137.297 Y134.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.221 Y135.102 Z18.72 F42000
G1 Z18.32
G1 E.8 F1800
; LINE_WIDTH: 0.975743
G1 F2629.837
M204 S6000
G1 X134.92 Y135.136 E.05899
; LINE_WIDTH: 0.932714
G1 F2769.105
G1 X134.62 Y135.169 E.05602
; LINE_WIDTH: 0.889684
G1 F2923.949
G1 X134.32 Y135.203 E.05305
; LINE_WIDTH: 0.845992
G1 F3000
G1 X134.01 Y135.238 E.05156
; LINE_WIDTH: 0.799709
G1 X133.759 Y135.263 E.03926
; LINE_WIDTH: 0.752736
G1 X133.507 Y135.288 E.03654
; LINE_WIDTH: 0.705763
G1 X133.255 Y135.313 E.03383
; LINE_WIDTH: 0.65879
G1 X133.003 Y135.338 E.03112
; LINE_WIDTH: 0.611817
G1 X132.751 Y135.363 E.0284
; LINE_WIDTH: 0.564844
G1 X132.499 Y135.388 E.02569
; LINE_WIDTH: 0.517871
G1 X132.247 Y135.413 E.02298
; LINE_WIDTH: 0.470898
G1 X131.995 Y135.439 E.02026
; LINE_WIDTH: 0.423925
G1 X131.743 Y135.464 E.01755
; WIPE_START
G1 X131.995 Y135.439 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.758 Y131.039 Z18.72 F42000
G1 X112.213 Y121.483 Z18.72
G1 Z18.32
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.419 Y123.615 I6.046 J6.911 E.44662
G1 X122.193 Y135.389 E2.65885
G3 X119.604 Y136.396 I-4.54 J-7.844 E.44541
G1 X130.798 Y125.202 E2.52781
G1 X130.798 Y130.798 E.89353
G1 X119.604 Y119.604 E2.52771
G3 X122.192 Y120.612 I-2.243 J9.587 E.44493
G1 X110.419 Y132.385 E2.65859
G2 X112.21 Y134.52 I7.844 J-4.761 E.44671
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 18.88
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.53 Y133.87 E-.35738
G1 X111.019 Y133.271 E-.29922
G1 X110.867 Y133.046 E-.1034
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 34/51
; update layer progress
M73 L34
M991 S0 P33 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z18.88 I-.048 J1.703 P1  F42000
G1 X132.275 Y133.646 Z18.88
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.275 Y121.451 E1.94735
G3 X135.189 Y122.235 I-11.324 J47.908 E.48205
G1 X142.284 Y124.427 E1.18563
G1 X142.284 Y124.712 E.04545
G1 F1500
G1 X142.284 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X142.284 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X142.284 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X142.284 Y131.573 E.04545
G1 X135.189 Y133.766 E1.18564
G3 X132.275 Y134.55 I-14.356 J-47.527 E.48206
G1 X132.275 Y133.766 E.12515
M204 S250
G1 X132.974 Y133.646 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X132.974 Y122.754 E1.73923
G1 X132.974 Y122.354 E.06387
G1 F1950
G1 X133.658 Y122.531 E.11281
G1 X134.046 Y122.631 E.06387
G1 F1650
G1 X134.988 Y122.905 E.15674
G1 F1380
G1 X137.378 Y123.644 E.39936
M106 S196.35
M106 S255
G1 F1260
G1 X141.011 Y124.766 E.60712
M106 S196.35
M106 S255
G1 F1140
G1 X141.584 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X141.584 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X141.584 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X141.584 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X141.202 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X139.194 Y131.796 E.33549
M106 S196.35
M106 S255
G1 F1260
G1 X135.562 Y132.918 E.6071
M106 S196.35
M106 S255
G1 F1380
G1 X134.988 Y133.095 E.0958
M106 S196.35
G1 F1650
G1 X134.056 Y133.367 E.15511
G1 F1950
G1 X133.091 Y133.616 E.15918
; WIPE_START
M204 S6000
G1 X133.069 Y131.617 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.614 Y124.004 Z19.28 F42000
G1 X133.82 Y121.127 Z19.28
G1 Z18.88
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X133.866 Y120.76 E.05907
G1 X146.72 Y120.762 E2.05238
G3 X147.357 Y121.491 I.022 J.624 E.17683
G3 X147.361 Y131.308 I-517.051 J5.109 E1.56756
G1 X147.373 Y131.497 E.03035
G3 X147.343 Y134.747 I-108.914 J.601 E.51898
G3 X146.807 Y135.221 I-.546 J-.077 E.12439
G1 X146.383 Y135.241 E.06767
G1 X133.866 Y135.241 E1.9987
G1 X133.819 Y134.874 E.05906
G2 X135.39 Y134.436 I-6.411 J-26.049 E.26045
G1 X142.984 Y132.09 E1.26902
G1 X142.984 Y131.472 E.09854
G1 X142.984 Y131.072 E.06387
G1 F2550
G1 X142.984 Y124.928 E.98112
G1 F3215.099
G1 X142.984 Y124.528 E.06387
G1 X142.984 Y123.911 E.09854
G1 X135.391 Y121.565 E1.26897
G2 X133.936 Y121.156 I-7.921 J25.391 E.2413
; WIPE_START
G1 X133.866 Y120.76 E-.15276
G1 X135.464 Y120.76 E-.60724
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.832 Y120.647 Z19.28 F42000
G1 X123.579 Y120.585 Z19.28
G1 Z18.88
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X123.655 Y120.605 E.01247
G2 X124.729 Y120.76 I1.157 J-4.225 E.1737
G1 X131.575 Y120.76 E1.09318
G1 X131.575 Y135.241 E2.31222
G1 X124.746 Y135.241 E1.09039
G2 X122.77 Y135.745 I.029 J4.241 E.32882
G3 X118.187 Y118.819 I-4.958 J-7.741 E5.50736
G3 X122.767 Y120.254 I-.417 J9.356 E.77497
G2 X123.155 Y120.435 I2.044 J-3.874 E.06842
G1 X123.466 Y120.545 E.05264
M204 S10000
G1 X123.802 Y119.922 F42000
G1 F3215.099
M204 S6000
G1 X123.84 Y119.931 E.00625
G2 X124.744 Y120.06 I.963 J-3.519 E.14624
G1 X146.419 Y120.06 E3.4609
G3 X147.3 Y120.181 I.145 J2.207 E.14295
G3 X148.057 Y121.488 I-.558 J1.196 E.25678
G3 X148.058 Y134.615 I-1107.821 J6.673 E2.096
G3 X146.729 Y135.925 I-1.279 J.032 E.33396
G1 X146.399 Y135.94 E.05277
G1 X124.755 Y135.94 E3.45607
G2 X123.103 Y136.361 I.02 J3.537 E.27492
G3 X118.209 Y118.12 I-5.291 J-8.357 E5.91708
G3 X123.101 Y119.639 I-.437 J10.04 E.82693
G2 X123.42 Y119.788 I1.703 J-3.226 E.05633
G1 X123.688 Y119.882 E.04541
M204 S250
G1 X124.144 Y119.285 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.365 Y119.329 E.03598
G2 X124.76 Y119.36 I.43 J-2.884 E.06319
G1 X146.423 Y119.36 E3.45905
G3 X148.024 Y119.811 I.216 J2.302 E.27175
G3 X148.757 Y121.486 I-1.319 J1.574 E.30248
G3 X148.758 Y134.646 I-1114.757 J6.697 E2.10136
G3 X146.652 Y136.63 I-1.987 J0 E.51735
G1 X124.764 Y136.64 E3.49504
G2 X123.435 Y136.977 I.01 J2.833 E.22103
G3 X107.371 Y129.78 I-5.62 J-8.984 E3.3168
G3 X118.232 Y117.42 I10.44 J-1.778 E3.00868
G3 X123.434 Y119.024 I-.457 J10.726 E.8789
G2 X124.025 Y119.257 I1.361 J-2.579 E.1016
G1 X124.028 Y119.258 E.00042
; WIPE_START
M204 S6000
G1 X124.365 Y119.329 E-.13119
G1 X124.76 Y119.36 E-.15027
G1 X126.019 Y119.36 E-.47854
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


G1 X135.377 Y121.152 F42000
G1 Z18.88
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.243686
G1 F3000
M204 S6000
G1 X135.569 Y121.181 E.00547
; LINE_WIDTH: 0.292344
G1 X135.761 Y121.21 E.00763
; LINE_WIDTH: 0.341002
G1 X135.953 Y121.239 E.00979
; LINE_WIDTH: 0.389659
G1 X136.145 Y121.268 E.01195
; LINE_WIDTH: 0.438317
G1 X136.337 Y121.297 E.0141
; LINE_WIDTH: 0.486975
G1 X136.529 Y121.326 E.01626
; LINE_WIDTH: 0.535633
G1 X136.721 Y121.355 E.01842
; LINE_WIDTH: 0.584291
G1 X136.913 Y121.383 E.02057
; LINE_WIDTH: 0.632949
G1 X137.106 Y121.412 E.02273
; LINE_WIDTH: 0.681606
G1 X137.298 Y121.441 E.02489
; LINE_WIDTH: 0.730264
G1 X137.49 Y121.47 E.02704
; LINE_WIDTH: 0.778922
G1 X137.682 Y121.499 E.0292
; LINE_WIDTH: 0.82758
G1 X137.874 Y121.528 E.03136
; LINE_WIDTH: 0.876238
G1 F2975.952
G1 X138.066 Y121.557 E.03351
; LINE_WIDTH: 0.924896
G1 F2796.009
G1 X138.258 Y121.586 E.03567
; WIPE_START
G1 X138.066 Y121.557 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.28 I-1.217 J.018 P1  F42000
G1 X138.258 Y134.414 Z19.28
G1 Z18.88
G1 E.8 F1800
; LINE_WIDTH: 0.924907
G1 F2795.968
M204 S6000
G1 X138.066 Y134.443 E.03567
; LINE_WIDTH: 0.876248
G1 F2975.912
G1 X137.874 Y134.472 E.03351
; LINE_WIDTH: 0.827588
G1 F3000
G1 X137.682 Y134.501 E.03136
; LINE_WIDTH: 0.778929
G1 X137.49 Y134.53 E.0292
; LINE_WIDTH: 0.730269
G1 X137.298 Y134.559 E.02704
; LINE_WIDTH: 0.68161
G1 X137.106 Y134.588 E.02489
; LINE_WIDTH: 0.63295
G1 X136.913 Y134.617 E.02273
; LINE_WIDTH: 0.58429
G1 X136.721 Y134.646 E.02057
; LINE_WIDTH: 0.535631
G1 X136.529 Y134.675 E.01842
; LINE_WIDTH: 0.486971
G1 X136.337 Y134.704 E.01626
; LINE_WIDTH: 0.438312
G1 X136.145 Y134.733 E.0141
; LINE_WIDTH: 0.389652
G1 X135.953 Y134.762 E.01195
; LINE_WIDTH: 0.340993
G1 X135.761 Y134.791 E.00979
; LINE_WIDTH: 0.292333
G1 X135.569 Y134.82 E.00763
; LINE_WIDTH: 0.243674
G1 X135.377 Y134.849 E.00547
M204 S10000
G1 X142.057 Y133.841 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X145.961 Y133.841 E.62336
G2 X145.961 Y122.162 I-928.677 J-5.845 E1.86487
G1 X142.062 Y122.161 E.62256
G1 X143.643 Y122.65 E.26434
G1 X144.091 Y122.926 E.08399
G1 X144.321 Y123.296 E.06953
G1 X144.383 Y123.653 E.05784
G1 X144.383 Y132.351 E1.38883
M73 P78 R4
G1 X144.32 Y132.706 E.05755
G1 X144.09 Y133.075 E.06946
G1 X143.643 Y133.351 E.08387
G1 X142.171 Y133.806 E.24603
; WIPE_START
G1 X143.643 Y133.351 E-.58551
G1 X144.034 Y133.11 E-.17449
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.848 Y125.521 Z19.28 F42000
G1 X145.117 Y123.008 Z19.28
G1 Z18.88
G1 E.8 F1800
; LINE_WIDTH: 1.09513
G1 F2307.803
M204 S6000
G1 X145.136 Y123.221 E.04752
; LINE_WIDTH: 1.05824
G1 F2398.567
G1 X145.155 Y123.434 E.04572
; LINE_WIDTH: 1.00945
G1 F2530.169
G3 X145.174 Y123.653 I-1.25 J.22 E.04467
G3 X145.174 Y132.348 I-1382.042 J4.274 E1.7642
; LINE_WIDTH: 1.02061
G1 F2498.806
G1 X145.158 Y132.523 E.03624
; LINE_WIDTH: 1.05787
G1 F2399.514
G1 X145.143 Y132.699 E.03774
; LINE_WIDTH: 1.09513
G1 F2307.811
G1 X145.127 Y132.875 E.03924
; WIPE_START
G1 X145.143 Y132.699 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.28 I1.054 J-.609 P1  F42000
G1 X138.915 Y121.921 Z19.28
G1 Z18.88
G1 E.8 F1800
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X143.437 Y123.318 E.75561
G1 X143.586 Y123.411 E.028
G1 X143.683 Y123.652 E.04151
G1 X143.683 Y132.349 E1.38871
G3 X143.437 Y132.682 I-.386 J-.027 E.06988
G1 X138.916 Y134.079 E.75561
G1 X138.985 Y134.541 E.07454
G1 X146.369 Y134.541 E1.1791
G1 X146.658 Y134.526 E.0462
G2 X146.654 Y121.466 I-1120.651 J-6.16 E2.08534
G2 X138.985 Y121.461 I-4.888 J1493.222 E1.22458
G1 X138.933 Y121.803 E.05522
; WIPE_START
G1 X138.985 Y121.461 E-.13142
G1 X140.639 Y121.462 E-.62858
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.28 I-.508 J-1.106 P1  F42000
G1 X112.21 Y134.52 Z19.28
G1 Z18.88
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.663 J-6.569 E.44691
G1 X122.192 Y120.612 E2.6586
G2 X119.604 Y119.604 I-4.835 J8.592 E.44491
G1 X130.98 Y130.98 E2.56877
G1 X130.98 Y125.02 E.95164
G1 X119.604 Y136.396 E2.56891
G2 X122.193 Y135.389 I-1.726 J-8.273 E.44569
G1 X110.424 Y123.62 E2.6578
G3 X112.212 Y121.485 I7.618 J4.566 E.44656
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 19.44
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.099
G1 X111.161 Y122.552 E-.56929
G1 X110.875 Y122.965 E-.19071
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 35/51
; update layer progress
M73 L35
M991 S0 P34 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z19.44 I-.715 J1.547 P1  F42000
G1 X133.936 Y133.62 Z19.44
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.457 Y134.078 E.24729
G1 X132.457 Y121.923 E1.94079
G1 X140.56 Y124.427 E1.35432
G1 X140.56 Y124.712 E.04545
G1 F1500
G1 X140.56 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X140.56 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X140.56 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X140.56 Y131.573 E.04545
G1 X134.051 Y133.585 E1.08787
M204 S250
G1 X133.73 Y132.952 F42000
; FEATURE: Outer wall
G1 F1380
M204 S5000
G1 X133.156 Y133.129 E.0958
M106 S196.35
M106 S255
G1 F3215.099
G1 X133.156 Y132.729 E.06387
G1 X133.156 Y123.272 E1.51008
G1 X133.156 Y122.872 E.06387
G1 F1380
G1 X135.2 Y123.503 E.34153
M106 S196.35
M106 S255
G1 X135.582 Y123.621 E.06387
M106 S196.35
M106 S255
G1 F1260
G1 X139.287 Y124.766 E.6192
M106 S196.35
M106 S255
G1 F1140
G1 X139.86 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X139.86 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X139.86 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X139.86 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X139.478 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X137.435 Y131.807 E.34153
M106 S196.35
M106 S255
G1 F1260
G1 X133.844 Y132.916 E.60004
M106 S196.35
; WIPE_START
M204 S6000
G1 X133.156 Y133.129 E-.2736
G1 X133.156 Y132.729 E-.152
G1 X133.156 Y131.849 E-.3344
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.84 I1.212 J-.106 P1  F42000
G1 X132.219 Y121.117 Z19.84
G1 Z19.44
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.273 Y120.76 E.05768
G1 X144.36 Y120.76 E1.92994
G1 X145.134 Y120.773 E.12366
G3 X146.643 Y120.888 I-1.315 J27.266 E.24173
G3 X146.96 Y120.991 I-.02 J.6 E.05389
G3 X147.152 Y121.661 I-.639 J.545 E.11486
G3 X147.143 Y134.663 I-195.002 J6.366 E2.07647
G3 X146.92 Y135.039 I-.575 J-.087 E.0715
G3 X146.366 Y135.143 I-.589 J-1.603 E.09041
G1 X145.787 Y135.179 E.09257
G2 X144.352 Y135.241 I3.568 J99.514 E.22945
G1 X132.273 Y135.241 E1.92869
G1 X132.219 Y134.883 E.05768
G1 X141.26 Y132.09 E1.51098
G1 X141.26 Y131.472 E.09854
G1 X141.26 Y131.072 E.06387
G1 F2550
G1 X141.26 Y124.928 E.98112
G1 F3215.099
G1 X141.26 Y124.528 E.06387
G1 X141.26 Y123.911 E.09854
G1 X132.334 Y121.152 E1.49182
; WIPE_START
G1 X132.273 Y120.76 E-.15097
G1 X133.876 Y120.76 E-.60903
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.244 Y120.63 Z19.84 F42000
G1 X123.58 Y120.585 Z19.84
G1 Z19.44
G1 E.8 F1800
G1 F3215.099
M204 S6000
M73 P78 R3
G1 X123.655 Y120.605 E.01246
G2 X124.728 Y120.76 I1.156 J-4.224 E.17361
G1 X131.757 Y120.76 E1.12226
G1 X131.757 Y135.241 E2.31222
G1 X124.746 Y135.241 E1.11944
G2 X122.77 Y135.745 I.029 J4.241 E.32885
G3 X118.196 Y118.82 I-4.957 J-7.741 E5.50808
G3 X122.767 Y120.254 I-.427 J9.356 E.77345
G2 X123.154 Y120.435 I2.044 J-3.872 E.0682
G1 X123.466 Y120.545 E.05296
M204 S10000
G1 X123.802 Y119.922 F42000
G1 F3215.099
M204 S6000
G1 X123.84 Y119.931 E.00625
G2 X124.744 Y120.06 I.963 J-3.518 E.14614
G1 X144.366 Y120.06 E3.1331
G3 X146.76 Y120.196 I-.246 J25.486 E.38299
G3 X147.847 Y121.358 I-.113 J1.196 E.27781
G3 X147.834 Y134.77 I-198.273 J6.515 E2.14206
G3 X147.179 Y135.69 I-1.198 J-.16 E.1876
G3 X146.431 Y135.84 I-.842 J-2.257 E.12235
G1 X145.751 Y135.894 E.10894
M73 P79 R3
G1 X145.705 Y135.881 E.00755
G2 X144.361 Y135.94 I5.873 J149.309 E.21488
G1 X124.755 Y135.94 E3.13059
G2 X123.102 Y136.361 I.02 J3.537 E.27496
G3 X118.219 Y118.12 I-5.29 J-8.358 E5.91776
G3 X123.1 Y119.639 I-.446 J10.04 E.82543
G2 X123.419 Y119.788 I1.702 J-3.225 E.05611
G1 X123.689 Y119.883 E.04575
M204 S250
G1 X124.134 Y119.283 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.367 Y119.329 E.03792
G2 X124.76 Y119.36 I.428 J-2.884 E.06295
G1 X144.372 Y119.36 E3.13158
G3 X146.876 Y119.504 I-.261 J26.351 E.40063
G3 X148.194 Y120.287 I-.223 J1.876 E.25197
G3 X148.551 Y121.626 I-1.816 J1.202 E.22532
G3 X148.535 Y134.807 I-194.318 J6.358 E2.10496
G3 X146.88 Y136.496 I-1.893 J-.2 E.4075
G3 X145.685 Y136.601 I-2.456 J-21.03 E.19149
G1 X145.623 Y136.584 E.01029
G2 X144.37 Y136.64 I18.807 J434.448 E.2003
G1 X124.764 Y136.64 E3.13062
G2 X123.435 Y136.977 I.01 J2.833 E.22105
G3 X118.241 Y117.421 I-5.623 J-8.974 E6.32751
G3 X123.434 Y119.023 I-.466 J10.726 E.8774
G2 X124.017 Y119.255 I1.361 J-2.578 E.10034
; WIPE_START
M204 S6000
G1 X124.367 Y119.329 E-.13581
G1 X124.76 Y119.36 E-.14971
G1 X126.008 Y119.36 E-.47448
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


G1 X133.658 Y121.152 F42000
G1 Z19.44
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242922
G1 F3000
M204 S6000
G1 X133.85 Y121.181 E.00543
; LINE_WIDTH: 0.291611
G1 X134.041 Y121.21 E.00759
; LINE_WIDTH: 0.340301
G1 X134.233 Y121.239 E.00974
; LINE_WIDTH: 0.388991
G1 X134.425 Y121.267 E.0119
; LINE_WIDTH: 0.43768
G1 X134.617 Y121.296 E.01405
; LINE_WIDTH: 0.48637
G1 X134.809 Y121.325 E.01621
; LINE_WIDTH: 0.53506
G1 X135 Y121.354 E.01836
; LINE_WIDTH: 0.583749
G1 X135.192 Y121.383 E.02052
; LINE_WIDTH: 0.632439
G1 X135.384 Y121.412 E.02267
; LINE_WIDTH: 0.681129
G1 X135.576 Y121.441 E.02483
; LINE_WIDTH: 0.729818
G1 X135.768 Y121.47 E.02698
; LINE_WIDTH: 0.778508
G1 X135.959 Y121.499 E.02914
; LINE_WIDTH: 0.827198
G1 X136.151 Y121.528 E.03129
; LINE_WIDTH: 0.875887
G1 F2977.332
G1 X136.343 Y121.557 E.03345
; LINE_WIDTH: 0.924577
G1 F2797.116
G1 X136.535 Y121.586 E.0356
M204 S10000
G1 X144.235 Y123.735 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.2018
G1 F2080.209
M204 S6000
G3 X144.239 Y132.144 I-619.51 J4.467 E2.07515
M204 S10000
G1 X143.359 Y123.653 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X143.359 Y132.348 E1.38835
G1 X143.267 Y132.909 E.09087
G1 X143.128 Y133.141 E.04317
G2 X145.091 Y133.101 I.38 J-29.697 E.31354
G2 X145.094 Y122.874 I-213.437 J-5.185 E1.63322
G2 X143.128 Y122.859 I-1.591 J81.687 E.31398
G1 X143.267 Y123.091 E.04317
G1 X143.34 Y123.534 E.0717
M204 S10000
G1 X140.333 Y122.16 F42000
G1 F3215.112
M204 S6000
G1 X141.92 Y122.65 E.26519
G1 X142.377 Y122.936 E.08605
G1 X142.604 Y123.316 E.07073
G1 X142.66 Y123.735 E.0675
G1 X142.66 Y132.348 E1.37523
G1 X142.604 Y132.685 E.05452
G1 X142.377 Y133.065 E.07073
G1 X141.92 Y133.351 E.08605
G1 X140.333 Y133.841 E.26519
G1 X144.311 Y133.841 E.63521
G3 X145.771 Y133.784 I2.636 J49.126 E.23333
G2 X145.774 Y122.216 I-196.015 J-5.831 E1.84738
G2 X144.348 Y122.16 I-1.311 J14.972 E.22804
G1 X140.453 Y122.16 E.62186
M204 S10000
G1 X137.192 Y121.921 F42000
G1 F3215.112
M204 S6000
G1 X141.713 Y123.318 E.75562
G1 X141.866 Y123.414 E.02868
G1 X141.96 Y123.653 E.04103
G1 X141.96 Y132.348 E1.38835
G1 X141.866 Y132.587 E.04103
G1 X141.713 Y132.682 E.02868
G1 X137.192 Y134.079 E.75562
G1 X137.262 Y134.541 E.07454
G1 X144.331 Y134.541 E1.12887
G3 X145.746 Y134.488 I1.414 J18.944 E.22603
G1 X146.453 Y134.416 E.11356
G2 X146.451 Y121.583 I-198.325 J-6.384 E2.04938
G2 X143.433 Y121.46 I-2.573 J25.892 E.48256
G1 X137.262 Y121.46 E.98545
G1 X137.21 Y121.803 E.05538
; WIPE_START
G1 X137.262 Y121.46 E-.13181
G1 X138.915 Y121.46 E-.62819
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z19.84 I-1.197 J-.22 P1  F42000
G1 X136.535 Y134.414 Z19.84
G1 Z19.44
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.924592
G1 F2797.065
M204 S6000
G1 X136.343 Y134.443 E.0356
; LINE_WIDTH: 0.875901
G1 F2977.277
G1 X136.151 Y134.472 E.03345
; LINE_WIDTH: 0.827211
G1 F3000
G1 X135.959 Y134.501 E.03129
; LINE_WIDTH: 0.77852
G1 X135.768 Y134.53 E.02914
; LINE_WIDTH: 0.72983
G1 X135.576 Y134.559 E.02698
; LINE_WIDTH: 0.681139
G1 X135.384 Y134.588 E.02483
; LINE_WIDTH: 0.632449
G1 X135.192 Y134.617 E.02267
; LINE_WIDTH: 0.583758
G1 X135 Y134.646 E.02052
; LINE_WIDTH: 0.535067
G1 X134.809 Y134.675 E.01836
; LINE_WIDTH: 0.486377
G1 X134.617 Y134.704 E.01621
; LINE_WIDTH: 0.437686
G1 X134.425 Y134.733 E.01405
; LINE_WIDTH: 0.388996
G1 X134.233 Y134.762 E.0119
; LINE_WIDTH: 0.340305
G1 X134.041 Y134.791 E.00974
; LINE_WIDTH: 0.291615
G1 X133.85 Y134.82 E.00759
; LINE_WIDTH: 0.242924
G1 X133.658 Y134.849 E.00543
; WIPE_START
G1 X133.85 Y134.82 E-.76
; WIPE_END
M73 P80 R3
G1 E-.04 F1800
M204 S10000
G1 X127.352 Y130.815 Z19.84 F42000
G1 X112.212 Y121.485 Z19.84
G1 Z19.44
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.424 Y123.62 I5.808 J6.682 E.44656
G1 X122.193 Y135.389 E2.65777
G3 X119.604 Y136.396 I-4.311 J-7.256 E.44564
G1 X131.162 Y124.838 E2.60994
G1 X131.162 Y131.162 E1.00974
G1 X119.604 Y119.604 E2.60984
G3 X122.192 Y120.612 I-2.25 J9.607 E.44488
G1 X110.419 Y132.385 E2.65859
G2 X112.21 Y134.52 I7.452 J-4.433 E.44692
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 20
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.235 Y133.538 E-.52573
G1 X110.879 Y133.035 E-.23427
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 36/51
; update layer progress
M73 L36
M991 S0 P35 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z20 I.04 J1.703 P1  F42000
G1 X131.939 Y132.54 Z20
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X131.939 Y121.563 E1.75275
G1 X139.537 Y123.911 E1.26979
G1 X139.537 Y124.528 E.09854
G1 X139.537 Y124.928 E.06387
G1 F2550
G1 X139.537 Y131.072 E.98112
G1 F3215.099
G1 X139.537 Y131.472 E.06387
G1 X139.537 Y132.09 E.09854
G1 X131.939 Y134.437 E1.26979
G1 X131.939 Y132.66 E.28381
M204 S10000
G1 X132.638 Y132.54 F42000
G1 F3215.099
M204 S6000
G1 X132.638 Y122.512 E1.60126
G1 X138.837 Y124.427 E1.03587
G1 X138.837 Y124.712 E.04545
G1 F1500
G1 X138.837 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X138.837 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X138.837 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X138.837 Y131.573 E.04545
G1 X132.638 Y133.489 E1.03587
G1 X132.638 Y132.66 E.13233
M204 S250
G1 X133.338 Y132.54 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X133.338 Y123.86 E1.38591
G1 X133.338 Y123.46 E.06387
G1 F1380
G1 X134.747 Y123.896 E.23539
M106 S196.35
M106 S255
G1 X135.129 Y124.014 E.06387
M106 S196.35
M106 S255
G1 F1260
G1 X137.564 Y124.766 E.4069
M106 S196.35
M106 S255
G1 F1140
G1 X138.137 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X138.137 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X138.137 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X138.137 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X137.755 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X136.346 Y131.611 E.23539
M106 S196.35
M106 S255
G1 F1260
G1 X133.912 Y132.363 E.4069
M106 S196.35
M106 S255
G1 F1380
G1 X133.453 Y132.505 E.07664
M106 S196.35
; WIPE_START
M204 S6000
G1 X133.426 Y130.505 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.05 Y125.087 Z20.4 F42000
G1 X123.583 Y120.586 Z20.4
G1 Z20
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.655 Y120.609 E.01209
G2 X124.746 Y120.76 I1.121 J-4.091 E.17642
G1 X142.917 Y120.769 E2.90142
G1 X143.393 Y121.573 E.1491
G1 X144.044 Y125.093 E.57167
G1 X144.206 Y128 E.46488
G1 X144.044 Y130.907 E.46488
G1 X143.431 Y134.231 E.53963
G1 X142.622 Y135.236 E.2061
G1 X124.746 Y135.241 E2.85437
G2 X122.769 Y135.745 I.029 J4.241 E.32899
G3 X118.207 Y118.82 I-4.95 J-7.743 E5.50656
G3 X122.766 Y120.254 I-.437 J9.356 E.77167
G2 X123.151 Y120.437 I2.01 J-3.736 E.06819
G1 X123.469 Y120.547 E.0537
M204 S10000
G1 X123.804 Y119.923 F42000
G1 F3215.099
M204 S6000
G1 X123.84 Y119.934 E.00608
G2 X124.755 Y120.06 I.935 J-3.412 E.14787
G1 X142.317 Y120.06 E2.80429
G3 X143.323 Y120.083 I.204 J13.306 E.1607
G1 X144.053 Y121.314 E.22857
G1 X144.097 Y121.519 E.03348
G1 X144.74 Y125.01 E.56678
G1 X144.907 Y128 E.47821
G1 X144.74 Y130.99 E.47818
G1 X144.088 Y134.531 E.57498
G1 X142.967 Y135.924 E.28539
G3 X142.317 Y135.94 I-.742 J-16.313 E.10379
G1 X124.755 Y135.94 E2.80426
G2 X123.102 Y136.361 I.02 J3.536 E.27504
G3 X118.229 Y118.12 I-5.289 J-8.358 E5.91937
G3 X123.1 Y119.639 I-.457 J10.04 E.8237
G2 X123.417 Y119.789 I1.675 J-3.116 E.05606
G1 X123.69 Y119.884 E.04619
M204 S250
G1 X124.069 Y119.268 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.493 Y119.346 E.06876
G2 X124.764 Y119.36 I.281 J-2.819 E.0433
G1 X142.323 Y119.36 E2.8038
G3 X146.35 Y119.772 I.213 J17.813 E.64777
G3 X147.218 Y120.063 I-.688 J3.495 E.14657
G3 X147.906 Y121.057 I-.756 J1.258 E.19895
G3 X148.079 Y122.59 I-10.414 J1.949 E.24661
G3 X148.055 Y133.71 I-79.934 J5.388 E1.77692
G3 X147.969 Y134.642 I-39.513 J-3.166 E.14944
G3 X147.568 Y135.646 I-1.967 J-.204 E.17486
G3 X146.633 Y136.157 I-1.294 J-1.256 E.17272
G3 X143.644 Y136.567 I-3.095 J-11.454 E.48314
G3 X142.323 Y136.64 I-1.36 J-12.658 E.2113
G1 X124.764 Y136.64 E2.80377
G2 X123.435 Y136.977 I.01 J2.832 E.22109
G3 X118.251 Y117.421 I-5.623 J-8.974 E6.32943
G3 X123.434 Y119.023 I-.477 J10.726 E.87573
G2 X123.953 Y119.239 I1.34 J-2.496 E.08994
; WIPE_START
M204 S6000
G1 X124.493 Y119.346 E-.20911
G1 X124.764 Y119.36 E-.103
G1 X125.942 Y119.36 E-.44789
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


G1 X131.934 Y121.152 F42000
G1 Z20
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.242922
G1 F3000
M204 S6000
G1 X132.126 Y121.181 E.00543
; LINE_WIDTH: 0.291612
G1 X132.318 Y121.21 E.00759
; LINE_WIDTH: 0.340301
G1 X132.51 Y121.239 E.00974
; LINE_WIDTH: 0.388991
G1 X132.701 Y121.267 E.0119
; LINE_WIDTH: 0.437681
G1 X132.893 Y121.296 E.01405
; LINE_WIDTH: 0.486371
G1 X133.085 Y121.325 E.01621
; LINE_WIDTH: 0.535061
G1 X133.277 Y121.354 E.01836
; LINE_WIDTH: 0.58375
G1 X133.469 Y121.383 E.02052
; LINE_WIDTH: 0.63244
G1 X133.66 Y121.412 E.02267
; LINE_WIDTH: 0.68113
G1 X133.852 Y121.441 E.02483
; LINE_WIDTH: 0.72982
G1 X134.044 Y121.47 E.02698
; LINE_WIDTH: 0.778509
G1 X134.236 Y121.499 E.02914
; LINE_WIDTH: 0.827199
G1 X134.428 Y121.528 E.03129
; LINE_WIDTH: 0.875889
G1 F2977.325
G1 X134.619 Y121.557 E.03345
; LINE_WIDTH: 0.924579
G1 F2797.11
G1 X134.811 Y121.586 E.0356
; WIPE_START
G1 X134.619 Y121.557 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.4 I-1.217 J.018 P1  F42000
G1 X134.811 Y134.414 Z20.4
G1 Z20
G1 E.8 F1800
; LINE_WIDTH: 0.924592
G1 F2797.065
M204 S6000
G1 X134.619 Y134.443 E.0356
; LINE_WIDTH: 0.875901
G1 F2977.277
G1 X134.428 Y134.472 E.03345
; LINE_WIDTH: 0.827211
G1 F3000
G1 X134.236 Y134.501 E.03129
; LINE_WIDTH: 0.77852
G1 X134.044 Y134.53 E.02914
; LINE_WIDTH: 0.72983
G1 X133.852 Y134.559 E.02698
; LINE_WIDTH: 0.681139
G1 X133.66 Y134.588 E.02483
; LINE_WIDTH: 0.632448
G1 X133.469 Y134.617 E.02267
; LINE_WIDTH: 0.583758
G1 X133.277 Y134.646 E.02052
; LINE_WIDTH: 0.535067
G1 X133.085 Y134.675 E.01836
; LINE_WIDTH: 0.486377
G1 X132.893 Y134.704 E.01621
; LINE_WIDTH: 0.437686
G1 X132.701 Y134.733 E.01405
; LINE_WIDTH: 0.388996
G1 X132.51 Y134.762 E.0119
; LINE_WIDTH: 0.340305
G1 X132.318 Y134.791 E.00974
; LINE_WIDTH: 0.291615
G1 X132.126 Y134.82 E.00759
; LINE_WIDTH: 0.242924
G1 X131.934 Y134.849 E.00543
M204 S10000
G1 X138.621 Y133.837 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X141.952 Y133.837 E.53183
G1 X142.119 Y133.629 E.04261
G1 X142.652 Y130.74 E.46894
G1 X142.801 Y127.948 E.44651
G1 X142.652 Y125.26 E.42988
G1 X142.08 Y122.169 E.50199
G1 X138.633 Y122.167 E.55032
G1 X140.196 Y122.65 E.26123
G1 X140.597 Y122.88 E.07386
G1 X140.833 Y123.199 E.06322
G1 X140.936 Y123.643 E.07285
G1 X140.936 Y132.348 E1.3899
G1 X140.87 Y132.714 E.05935
M73 P81 R3
G1 X140.597 Y133.121 E.07837
G1 X140.196 Y133.351 E.07368
G1 X138.736 Y133.802 E.24411
; WIPE_START
G1 X140.196 Y133.351 E-.58094
G1 X140.597 Y133.121 E-.17535
G1 X140.602 Y133.113 E-.00372
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.256 Y125.508 Z20.4 F42000
G1 X141.481 Y122.888 Z20.4
G1 Z20
G1 E.8 F1800
; LINE_WIDTH: 0.840931
G1 F3121.729
M204 S6000
G1 X141.639 Y123.653 E.12849
; LINE_WIDTH: 0.848977
G1 F3087.267
G1 X141.662 Y123.897 E.04079
; LINE_WIDTH: 0.893777
G1 F2908.48
G1 X141.684 Y124.141 E.04329
; LINE_WIDTH: 0.938577
G1 F2749.267
G1 X141.706 Y124.386 E.0458
; LINE_WIDTH: 0.983377
G1 F2606.58
G1 X141.729 Y124.63 E.04831
; LINE_WIDTH: 1.02818
G1 F2477.974
G1 X141.751 Y124.874 E.05082
; LINE_WIDTH: 1.07298
G1 F2361.461
G1 X141.774 Y125.118 E.05332
; LINE_WIDTH: 1.11778
G1 F2255.413
G1 X141.796 Y125.363 E.05583
; LINE_WIDTH: 1.16466
G1 F2154.168
G1 X141.821 Y126.242 E.2096
; LINE_WIDTH: 1.21364
G1 F2057.688
G1 X141.845 Y127.121 E.21943
; LINE_WIDTH: 1.26261
G1 F1969.48
G1 X141.87 Y128 E.22925
G1 X141.845 Y128.879 E.22931
; LINE_WIDTH: 1.21364
G1 F2057.688
G1 X141.821 Y129.759 E.21948
; LINE_WIDTH: 1.16466
G1 F2154.168
G1 X141.796 Y130.638 E.20965
; LINE_WIDTH: 1.11785
G1 F2255.242
G1 X141.774 Y130.882 E.05582
; LINE_WIDTH: 1.0732
G1 F2360.899
G1 X141.751 Y131.127 E.05332
; LINE_WIDTH: 1.02856
G1 F2476.941
G1 X141.729 Y131.371 E.05083
; LINE_WIDTH: 0.983907
G1 F2604.981
G1 X141.707 Y131.615 E.04833
; LINE_WIDTH: 0.939258
G1 F2746.98
G1 X141.684 Y131.859 E.04583
; LINE_WIDTH: 0.89461
G1 F2905.352
G1 X141.662 Y132.103 E.04333
; LINE_WIDTH: 0.833483
G1 F3154.326
G3 X141.516 Y133.001 I-8.455 J-.918 E.14813
; WIPE_START
G1 X141.64 Y132.348 E-.55532
G1 X141.662 Y132.103 E-.20468
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.4 I1.04 J-.632 P1  F42000
G1 X135.468 Y121.921 Z20.4
G1 Z20
G1 E.8 F1800
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X139.99 Y123.318 E.75562
G1 X140.123 Y123.395 E.02462
G1 X140.231 Y123.589 E.03536
G1 X140.236 Y132.348 E1.39852
G3 X139.99 Y132.682 I-.378 J-.021 E.07022
G1 X135.468 Y134.079 E.75562
G1 X135.538 Y134.538 E.0741
G1 X142.287 Y134.536 E1.07769
G1 X142.775 Y133.93 E.12435
G1 X143.348 Y130.824 E.50428
G1 X143.5 Y127.909 E.46601
G1 X143.348 Y125.177 E.437
G1 X142.727 Y121.822 E.54466
G1 X142.518 Y121.469 E.06559
G1 X135.537 Y121.465 E1.11465
G1 X135.486 Y121.803 E.05446
; WIPE_START
G1 X135.537 Y121.465 E-.12961
G1 X137.196 Y121.466 E-.63039
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.4 I-1.026 J.655 P1  F42000
G1 X146.429 Y135.92 Z20.4
G1 Z20
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.855927
G1 F3058.104
M204 S2000
G1 X147.184 Y135.164 E.17933
G2 X147.417 Y134.207 I-2.062 J-1.008 E.16674
G3 X147.439 Y133.869 I1.718 J-.058 E.05688
G1 X145.52 Y135.788 E.45561
G3 X144.316 Y135.952 I-2.547 J-14.269 E.20397
G1 X147.533 Y132.735 E.76363
G2 X147.585 Y131.642 I-20.851 J-1.55 E.18373
G1 X144.692 Y134.536 E.68697
G1 X144.927 Y133.26 E.21777
G1 X147.626 Y130.554 E.64152
G2 X147.65 Y129.497 I-55.37 J-1.79 E.17762
G1 X145.162 Y131.984 E.59059
G1 X145.332 Y131.061 E.15759
G1 X145.349 Y130.757 E.05119
G1 X147.66 Y128.446 E.54849
G3 X147.661 Y127.404 I500.591 J.204 E.17493
G1 X145.411 Y129.655 E.53427
G1 X145.472 Y128.553 E.18527
G1 X147.648 Y126.377 E.5166
G2 X147.62 Y125.365 I-33.307 J.432 E.16996
G1 X145.475 Y127.509 E.50902
G1 X145.421 Y126.523 E.16571
G1 X147.59 Y124.353 E.51513
G3 X147.538 Y123.365 I27.797 J-1.965 E.16614
G1 X145.366 Y125.538 E.51577
G2 X145.269 Y124.594 I-3.758 J-.091 E.15966
G1 X147.465 Y122.397 E.52148
G2 X147.379 Y121.443 I-35.998 J2.779 E.16083
G1 X145.107 Y123.715 E.53941
G1 X144.945 Y122.837 E.14998
G1 X147.078 Y120.704 E.50632
G2 X146.535 Y120.442 I-.666 J.686 E.10286
G1 X146.351 Y120.39 E.03215
G1 X144.783 Y121.958 E.37224
G2 X144.611 Y121.089 I-12.75 J2.066 E.14872
G1 X145.496 Y120.205 E.20999
G2 X144.585 Y120.075 I-1.379 J6.433 E.15459
G1 X143.994 Y120.666 E.14021
; WIPE_START
M204 S6000
G1 X144.585 Y120.075 E-.31739
G1 X145.496 Y120.205 E-.34965
G1 X145.323 Y120.378 E-.09296
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.304 Y123.375 Z20.4 F42000
G1 X112.211 Y134.518 Z20.4
G1 Z20
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.423 Y132.381 I5.82 J-6.685 E.44671
G1 X122.192 Y120.612 E2.65759
G2 X119.604 Y119.604 I-4.843 J8.614 E.44486
G1 X131.344 Y131.344 E2.65091
G1 X131.344 Y124.656 E1.06785
G1 X119.596 Y136.404 E2.6528
G2 X122.193 Y135.389 I-1.992 J-8.932 E.44699
G1 X110.419 Y123.615 E2.65891
G3 X112.214 Y121.483 I7.77 J4.723 E.44672
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 20.56
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.401 Y122.273 E-.43065
G1 X110.888 Y122.903 E-.30865
G1 X110.858 Y122.948 E-.0207
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 37/51
; update layer progress
M73 L37
M991 S0 P36 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z20.56 I-.664 J1.569 P1  F42000
G1 X132.121 Y131.951 Z20.56
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.121 Y122.152 E1.56471
G1 X137.813 Y123.911 E.95134
G1 X137.813 Y124.528 E.09854
G1 X137.813 Y124.928 E.06387
G1 F2550
G1 X137.813 Y131.072 E.98112
G1 F3215.099
G1 X137.813 Y131.472 E.06387
G1 X137.813 Y132.09 E.09854
G1 X132.121 Y133.849 E.95134
G1 X132.121 Y132.071 E.28381
M204 S10000
G1 X132.82 Y131.951 F42000
G1 F3215.099
M204 S6000
G1 X132.82 Y123.101 E1.41322
G1 X137.113 Y124.427 E.71742
G1 X137.113 Y124.712 E.04545
G1 F1500
G1 X137.113 Y125.475 E.12183
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X137.113 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X137.113 Y131.289 E.12183
M106 S196.35
M106 S255
G1 F3215.099
G1 X137.113 Y131.573 E.04545
G1 X132.82 Y132.9 E.71742
G1 X132.82 Y132.071 E.13233
M204 S250
G1 X133.52 Y131.951 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X133.52 Y124.449 E1.19787
G1 X133.52 Y124.049 E.06387
G1 F1380
G1 X134.294 Y124.288 E.12924
M106 S196.35
M106 S255
G1 X134.676 Y124.406 E.06387
M106 S196.35
M106 S255
G1 F1260
G1 X135.84 Y124.766 E.1946
M106 S196.35
M106 S255
G1 F1140
G1 X136.413 Y124.943 E.0958
M106 S196.35
M106 S255
G1 F300
G1 X136.413 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X136.413 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X136.413 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X136.031 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X135.258 Y131.414 E.12924
M106 S196.35
M106 S255
G1 F1260
G1 X134.094 Y131.774 E.1946
M106 S196.35
M106 S255
G1 F1380
G1 X133.635 Y131.916 E.07664
M106 S196.35
; WIPE_START
M204 S6000
G1 X133.604 Y129.916 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.019 Y124.714 Z20.96 F42000
G1 X123.589 Y120.587 Z20.96
G1 Z20.56
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.677 Y120.607 E.01452
G2 X124.746 Y120.76 I1.174 J-4.386 E.17279
G1 X140.262 Y120.76 E2.47756
G1 X141.118 Y120.773 E.13658
G1 X141.402 Y121.668 E.14995
G3 X142.114 Y125.216 I-60.027 J13.895 E.57792
G2 X142.274 Y128 I335.898 J-17.907 E.44533
G2 X142.115 Y130.784 I334.231 J20.603 E.44519
G1 X141.514 Y134.034 E.52781
G1 X141.178 Y134.969 E.15866
G1 X141.164 Y135.218 E.03976
G3 X140.262 Y135.241 I-1.021 J-22.627 E.14409
G1 X124.746 Y135.241 E2.47754
G2 X122.769 Y135.745 I.095 J4.497 E.32872
G3 X118.216 Y118.82 I-4.955 J-7.742 E5.5111
G3 X122.765 Y120.253 I-.448 J9.358 E.77006
G2 X123.152 Y120.431 I2.086 J-4.033 E.06792
G1 X123.476 Y120.547 E.05493
M204 S10000
G1 X123.808 Y119.924 F42000
G1 F3215.099
M204 S6000
G1 X123.855 Y119.931 E.00746
G2 X124.755 Y120.06 I.984 J-3.659 E.14557
G1 X140.268 Y120.06 E2.47705
G3 X141.643 Y120.104 I.192 J15.449 E.21981
G1 X142.031 Y121.359 E.20977
G1 X142.065 Y121.42 E.01098
G3 X142.811 Y125.133 I-62.822 J14.553 E.60485
M73 P82 R3
G2 X142.976 Y128 I345.313 J-18.404 E.45861
G2 X142.811 Y130.867 I343.614 J21.182 E.4585
G1 X142.191 Y134.217 E.54403
G1 X141.871 Y135.109 E.15135
G1 X141.83 Y135.863 E.12053
G3 X140.268 Y135.94 I-1.572 J-15.927 E.24988
G1 X124.755 Y135.94 E2.47706
G2 X123.102 Y136.361 I.075 J3.753 E.2748
G3 X118.239 Y118.121 I-5.289 J-8.358 E5.92093
G3 X123.099 Y119.638 I-.468 J10.041 E.82206
G2 X123.417 Y119.784 I1.739 J-3.366 E.05583
G1 X123.695 Y119.884 E.0472
M204 S250
G1 X123.979 Y119.244 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.032 Y119.255 E.00864
G2 X124.764 Y119.36 I.794 J-2.931 E.11836
G1 X140.274 Y119.36 E2.47655
G3 X144.236 Y119.745 I.238 J18.124 E.63691
G3 X145.075 Y119.998 I-.983 J4.798 E.14016
G2 X145.549 Y120.204 I1.176 J-2.053 E.08271
G1 X145.87 Y120.438 E.06346
G3 X145.955 Y120.6 I-.896 J.575 E.02918
G1 X146.068 Y121.126 E.08592
G1 X146.74 Y124.771 E.59179
G1 X146.92 Y128 E.51646
G1 X146.74 Y131.229 E.5164
G1 X145.991 Y135.293 E.6598
G3 X145.692 Y135.708 I-.767 J-.236 E.0831
G3 X144.702 Y136.132 I-2.268 J-3.926 E.17237
G3 X142.21 Y136.534 I-2.918 J-10.178 E.4041
G3 X140.274 Y136.64 I-1.994 J-18.602 E.30975
G1 X124.764 Y136.64 E2.47657
G2 X123.435 Y136.977 I.055 J3.008 E.22089
G3 X118.261 Y117.421 I-5.623 J-8.975 E6.33076
G3 X123.434 Y119.023 I-.487 J10.726 E.87411
G2 X123.682 Y119.137 I1.392 J-2.698 E.04372
G1 X123.866 Y119.203 E.03115
; WIPE_START
M204 S6000
G1 X124.032 Y119.255 E-.06604
G1 X124.494 Y119.347 E-.17901
G1 X124.764 Y119.36 E-.10267
G1 X125.849 Y119.36 E-.41228
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


G1 X131.568 Y121.728 F42000
G1 Z20.56
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X131.659 Y121.405 E.05214
G1 X131.736 Y121.403 E.01196
M204 S10000
G1 X131.856 Y121.4 F42000
; LINE_WIDTH: 0.817507
G1 F3226.592
M204 S6000
G1 X138.266 Y123.318 E1.06453
G1 X138.46 Y123.468 E.03903
G1 X138.513 Y123.653 E.03049
G1 X138.513 Y132.348 E1.38341
G1 X138.463 Y132.528 E.02974
G1 X138.266 Y132.682 E.03976
G1 X132.243 Y134.543 E1.00301
G1 X140.591 Y134.532 E1.3282
G1 X140.836 Y133.851 E.11517
G1 X141.418 Y130.7 E.50988
G1 X141.568 Y127.912 E.44412
G1 X141.418 Y125.3 E.41641
G2 X140.725 Y121.848 I-59.051 J10.062 E.56024
G1 X140.603 Y121.465 E.06392
G3 X131.976 Y121.401 I2.28 J-891.753 E1.37264
M204 S10000
G1 X137.767 Y122.292 F42000
; LINE_WIDTH: 1.08101
G1 F2341.708
M204 S6000
G1 X138.512 Y122.523 E.17103
G1 X139.168 Y123.03 E.18177
G1 X139.327 Y123.609 E.13158
; LINE_WIDTH: 1.02727
G1 F2480.438
G1 X139.304 Y123.683 E.01597
; LINE_WIDTH: 0.982571
G1 F2609.016
G1 X139.282 Y123.756 E.01518
; LINE_WIDTH: 0.937867
G1 F2751.654
G1 X139.26 Y123.83 E.0144
; LINE_WIDTH: 0.893163
G1 F2910.79
G1 X139.238 Y123.904 E.01361
; LINE_WIDTH: 0.848459
G1 F3089.463
G1 X139.216 Y123.978 E.01282
; LINE_WIDTH: 0.820695
G1 F3211.909
G2 X139.213 Y130.525 I1598.608 J4.018 E1.04639
; LINE_WIDTH: 0.843973
G1 F3108.611
G1 X139.237 Y130.889 E.06034
; LINE_WIDTH: 0.891925
G1 F2915.46
G1 X139.261 Y131.254 E.06433
; LINE_WIDTH: 0.939877
G1 F2744.907
G1 X139.285 Y131.619 E.06833
; LINE_WIDTH: 0.987829
G1 F2593.206
G1 X139.309 Y131.983 E.07233
; LINE_WIDTH: 1.04817
G1 F2424.594
G1 X139.333 Y132.348 E.07736
G1 X139.258 Y132.756 E.08779
; LINE_WIDTH: 1.09127
G1 F2316.966
G1 X139.183 Y132.96 E.04829
G1 X138.514 Y133.484 E.18822
G1 X137.809 Y133.702 E.16362
G1 X139.998 Y133.701 E.485
G2 X140.264 Y132.433 I-13.481 J-3.498 E.28727
; LINE_WIDTH: 1.03578
G1 F2457.395
G1 X140.354 Y132.079 E.07632
; LINE_WIDTH: 0.987829
G1 F2593.206
G1 X140.444 Y131.725 E.07233
; LINE_WIDTH: 0.939877
G1 F2744.907
G1 X140.534 Y131.371 E.06833
; LINE_WIDTH: 0.891925
G1 F2915.46
G1 X140.624 Y131.017 E.06433
; LINE_WIDTH: 0.821849
G1 F3206.625
G2 X140.725 Y130.568 I-1.685 J-.616 E.07378
G1 X140.87 Y127.953 E.4194
G1 X140.722 Y125.383 E.41201
G2 X140.44 Y123.866 I-392.624 J72.353 E.24705
; LINE_WIDTH: 0.848459
G1 F3089.463
G1 X140.401 Y123.792 E.01397
; LINE_WIDTH: 0.893163
G1 F2910.79
G1 X140.362 Y123.717 E.01483
; LINE_WIDTH: 0.937867
G1 F2751.654
G1 X140.323 Y123.643 E.01569
; LINE_WIDTH: 0.982571
G1 F2609.016
G1 X140.284 Y123.568 E.01654
; LINE_WIDTH: 1.02727
G1 F2480.438
G1 X140.245 Y123.493 E.0174
; LINE_WIDTH: 1.08133
G1 F2340.932
G3 X139.969 Y122.292 I27.67 J-7.003 E.27028
G1 X137.887 Y122.292 E.45662
M204 S10000
G1 X139.969 Y125.474 F42000
; LINE_WIDTH: 0.957954
G1 F2685.68
M204 S6000
G1 X139.994 Y126.316 E.16103
; LINE_WIDTH: 1.00631
G1 F2539.131
G1 X140.018 Y127.158 E.17032
; LINE_WIDTH: 1.05466
G1 F2407.748
G1 X140.042 Y128 E.17962
; LINE_WIDTH: 1.05467
G1 X140.019 Y128.802 E.17098
; LINE_WIDTH: 1.00635
G1 F2539.016
G1 X139.996 Y129.603 E.16214
; LINE_WIDTH: 0.95802
G1 F2685.466
G1 X139.973 Y130.405 E.1533
; WIPE_START
G1 X139.996 Y129.603 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.486 Y133.587 Z20.96 F42000
G1 X131.82 Y134.606 Z20.96
G1 Z20.56
G1 E.8 F1800
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G1 X131.66 Y134.598 E.02486
G1 X131.601 Y134.388 E.0338
; WIPE_START
G1 X131.66 Y134.598 E-.43795
G1 X131.82 Y134.606 E-.32205
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z20.96 I.79 J.926 P1  F42000
M73 P83 R3
G1 X146.032 Y122.472 Z20.96
G1 Z20.56
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.839447
G1 F3128.172
M204 S2000
G1 X143.832 Y120.272 E.51065
G1 X143.802 Y120.265 E.00494
G2 X142.626 Y120.084 I-2.181 J10.231 E.1954
G1 X145.869 Y123.326 E.75264
G1 X146.099 Y124.573 E.20808
G1 X142.551 Y121.026 E.82341
G2 X142.628 Y121.208 I.475 J-.092 E.0328
G1 X142.877 Y122.369 E.19478
G1 X146.195 Y125.687 E.77013
G1 X146.255 Y126.764 E.17706
G1 X143.143 Y123.652 E.72239
G1 X143.373 Y124.899 E.20808
G1 X146.315 Y127.842 E.683
G1 X146.324 Y128 E.02606
G1 X146.278 Y128.822 E.13506
G1 X143.454 Y125.998 E.65547
G2 X143.517 Y127.077 I128.92 J-6.914 E.17748
G1 X146.225 Y129.785 E.62851
G1 X146.171 Y130.749 E.15837
G1 X143.563 Y128.141 E.60527
G1 X143.506 Y129.101 E.15786
G1 X146.057 Y131.652 E.59208
G1 X145.899 Y132.511 E.14332
G1 X143.451 Y130.063 E.56814
G1 X143.388 Y131.017 E.15694
G1 X145.741 Y133.37 E.54601
G1 X145.582 Y134.229 E.14332
G1 X143.229 Y131.876 E.5461
G1 X143.071 Y132.734 E.14328
G1 X145.424 Y135.088 E.54618
G3 X145.373 Y135.204 I-.151 J.003 E.02141
G3 X144.79 Y135.471 I-1.486 J-2.466 E.1055
G1 X142.912 Y133.593 E.43599
G1 X142.743 Y134.441 E.14196
G1 X143.999 Y135.697 E.29144
G3 X143.14 Y135.855 I-2.054 J-8.728 E.14337
G1 X142.228 Y134.943 E.21165
; WIPE_START
M204 S6000
G1 X143.14 Y135.855 E-.49007
G1 X143.838 Y135.727 E-.26993
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.879 Y132.593 Z20.96 F42000
G1 X112.213 Y121.485 Z20.96
G1 Z20.56
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.424 Y123.62 I5.743 J6.628 E.44664
G1 X122.193 Y135.389 E2.6577
G3 X119.604 Y136.396 I-4.872 J-8.703 E.44499
G1 X131.526 Y124.474 E2.69203
G1 X131.526 Y131.526 E1.12596
G1 X119.605 Y119.605 E2.69198
G3 X122.192 Y120.612 I-2.261 J9.636 E.44484
G1 X110.424 Y132.38 E2.65744
G2 X112.21 Y134.518 I7.809 J-4.708 E.44655
M106 S255
; CHANGE_LAYER
; Z_HEIGHT: 21.12
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.099
G1 X111.237 Y133.541 E-.52381
G1 X110.881 Y133.032 E-.23619
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 38/51
; update layer progress
M73 L38
M991 S0 P37 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z21.12 I.132 J1.699 P1  F42000
G1 X132.303 Y131.362 Z21.12
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X132.303 Y122.74 E1.37671
G1 X136.09 Y123.911 E.6329
G1 X136.09 Y124.528 E.09852
G1 X136.09 Y124.928 E.06387
G1 F2550
G1 X136.09 Y131.072 E.98112
G1 F3215.099
G1 X136.09 Y131.472 E.06387
G1 X136.09 Y132.09 E.09852
G1 X132.303 Y133.26 E.6329
G1 X132.303 Y131.482 E.28384
M204 S10000
G1 X133.002 Y131.362 F42000
G1 F3215.099
M204 S6000
G1 X133.002 Y123.689 E1.22521
G1 X135.39 Y124.427 E.39898
G1 X135.39 Y124.712 E.04544
G1 F1500
G1 X135.39 Y125.475 E.12184
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
M204 S5000
G1 X135.39 Y130.526 E.80651
M106 S196.35
M106 S255
; FEATURE: Inner wall
G1 F1500
M204 S6000
G1 X135.39 Y131.289 E.12184
M106 S196.35
M106 S255
G1 F3215.099
G1 X135.39 Y131.573 E.04544
G1 X133.002 Y132.311 E.39898
G1 X133.002 Y131.482 E.13234
M204 S250
G1 X133.702 Y131.362 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X133.702 Y125.038 E1.00984
G1 X133.702 Y124.638 E.06387
G1 F1140
G1 X134.308 Y124.825 E.10119
M106 S196.35
M106 S255
G1 X134.69 Y124.943 E.06387
M106 S196.35
M106 S255
G1 F300
G1 X134.69 Y125.259 E.05033
M106 S196.35
M106 S255
; FEATURE: Overhang wall
G1 F1800
G1 X134.69 Y130.742 E.87557
M106 S196.35
M106 S255
; FEATURE: Outer wall
G1 F300
G1 X134.69 Y131.057 E.05033
M106 S196.35
M106 S255
G1 F1140
G1 X134.308 Y131.175 E.06387
M106 S196.35
M106 S255
G1 X133.817 Y131.327 E.08203
M106 S196.35
; WIPE_START
M204 S6000
G1 X133.78 Y129.327 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.987 Y124.359 Z21.52 F42000
G1 X123.588 Y120.587 Z21.52
G1 Z21.12
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.678 Y120.607 E.01472
G2 X124.746 Y120.76 I1.172 J-4.382 E.17271
G1 X138.213 Y120.76 E2.15032
G1 X139.063 Y120.773 E.13579
G1 X139.338 Y121.636 E.14468
G1 X139.414 Y121.774 E.02508
G1 X140.189 Y125.391 E.59066
G1 X140.343 Y128 E.41738
G1 X140.186 Y130.653 E.4243
G1 X139.661 Y133.483 E.45969
G1 X139.159 Y134.882 E.23724
G1 X138.995 Y135.225 E.06072
G3 X138.213 Y135.241 I-.784 J-19.622 E.12488
G1 X124.746 Y135.241 E2.15035
G2 X122.768 Y135.745 I.095 J4.498 E.32878
G3 X118.226 Y118.82 I-4.955 J-7.742 E5.51257
G3 X122.765 Y120.253 I-.459 J9.358 E.76838
G2 X123.15 Y120.43 I2.086 J-4.029 E.06776
G1 X123.475 Y120.546 E.05508
M204 S10000
G1 X123.808 Y119.924 F42000
G1 F3215.099
M204 S6000
G1 X123.855 Y119.931 E.00764
G2 X124.755 Y120.06 I.982 J-3.655 E.14551
G1 X138.219 Y120.06 E2.14983
G3 X139.584 Y120.099 I.02 J22.956 E.21806
G1 X139.984 Y121.358 E.21091
G1 X140.076 Y121.526 E.03055
G1 X140.884 Y125.296 E.61573
G1 X141.045 Y128 E.43252
G1 X140.882 Y130.738 E.43788
G1 X140.339 Y133.667 E.47567
G1 X139.806 Y135.151 E.25189
G1 X139.444 Y135.91 E.13414
G3 X138.219 Y135.94 I-1.384 J-30.66 E.19566
G1 X124.755 Y135.94 E2.14986
G2 X123.101 Y136.361 I.075 J3.754 E.27485
G3 X118.249 Y118.121 I-5.289 J-8.359 E5.9224
G3 X123.099 Y119.638 I-.478 J10.042 E.82041
G2 X123.416 Y119.784 I1.738 J-3.362 E.05565
G1 X123.695 Y119.883 E.04732
M204 S250
G1 X123.899 Y119.217 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.032 Y119.255 E.0221
G2 X124.764 Y119.36 I.793 J-2.928 E.11831
G1 X138.224 Y119.36 E2.14934
G3 X142.366 Y119.78 I.226 J18.392 E.66614
G3 X143.359 Y120.11 I-2.386 J8.833 E.16708
G3 X143.844 Y120.418 I-.581 J1.454 E.09231
G2 X143.967 Y120.707 I.75 J-.149 E.05046
G3 X144.81 Y124.894 I-70.817 J16.439 E.6822
G2 X144.989 Y128 I371.438 J-19.779 E.49676
G2 X144.81 Y131.106 I369.829 J22.802 E.49671
G1 X144.138 Y134.743 E.5906
G1 X143.862 Y135.511 E.13037
G1 X143.86 Y135.556 E.00717
G1 X143.602 Y135.764 E.05284
G3 X142.274 Y136.23 I-2.243 J-4.267 E.22549
G1 X141.942 Y136.316 E.0548
G1 X140.824 Y136.496 E.18085
G3 X138.225 Y136.64 I-2.682 J-24.86 E.41582
G1 X124.764 Y136.64 E2.14937
G2 X123.434 Y136.977 I.055 J3.009 E.22093
G3 X118.271 Y117.421 I-5.622 J-8.975 E6.33221
G3 X123.433 Y119.023 I-.498 J10.727 E.87246
G2 X123.681 Y119.137 I1.391 J-2.695 E.04358
G1 X123.787 Y119.175 E.01789
; WIPE_START
M204 S6000
G1 X124.032 Y119.255 E-.09815
G1 X124.495 Y119.347 E-.17923
G1 X124.764 Y119.36 E-.10233
G1 X125.765 Y119.36 E-.38029
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


G1 X131.896 Y134.285 F42000
G1 Z21.12
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.81961
G1 F3216.891
M204 S6000
G1 X131.893 Y134.541 E.04083
G1 X138.54 Y134.534 E1.06082
G1 X138.983 Y133.3 E.20922
G1 X139.49 Y130.568 E.44346
G1 X139.642 Y128 E.41051
G1 X139.499 Y125.588 E.38557
G1 X139.472 Y125.384 E.03284
G1 X138.751 Y122.022 E.54879
G1 X138.549 Y121.465 E.09458
G2 X131.884 Y121.46 I-3.642 J394.592 E1.06369
G1 X131.896 Y121.715 E.04087
G1 X131.75 Y122.266 E.09094
G1 X132.068 Y121.935 E.07324
G1 X136.543 Y123.319 E.74745
G1 X136.711 Y123.433 E.03247
G1 X136.789 Y123.653 E.0373
G1 X136.789 Y132.348 E1.38755
G1 X136.715 Y132.563 E.03644
G1 X136.543 Y132.682 E.03334
G1 X132.056 Y134.069 E.74944
G1 X131.751 Y133.77 E.06814
G1 X131.864 Y134.17 E.06628
M204 S10000
G1 X135.736 Y133.754 F42000
; LINE_WIDTH: 0.990528
G1 F2585.164
M204 S6000
G1 X137.985 Y133.754 E.44649
G1 X138.179 Y133.256 E.10625
; LINE_WIDTH: 0.945707
G1 F2725.523
G2 X138.37 Y132.423 I-4.154 J-1.395 E.16124
; LINE_WIDTH: 0.92463
G1 F2796.93
G1 X138.509 Y131.79 E.11899
; LINE_WIDTH: 0.882777
G1 F2950.433
G1 X138.648 Y131.156 E.1128
; LINE_WIDTH: 0.822398
G1 F3204.12
G1 X138.797 Y130.443 E.11683
G1 X138.941 Y128 E.392
G1 X138.787 Y125.531 E.39637
; LINE_WIDTH: 0.838817
G1 F3130.914
G1 X138.558 Y124.55 E.16529
; LINE_WIDTH: 0.876457
G1 F2975.089
G1 X138.328 Y123.568 E.17394
; LINE_WIDTH: 0.916695
G1 F2824.797
G1 X138.2 Y123.074 E.09271
; LINE_WIDTH: 0.978734
G1 F2620.675
G3 X137.988 Y122.24 I53.174 J-14.017 E.16864
G1 X135.695 Y122.24 E.44902
G1 X136.773 Y122.573 E.22099
G1 X137.318 Y122.941 E.12874
; LINE_WIDTH: 0.959802
G1 F2679.768
G1 X137.41 Y123.183 E.04962
; LINE_WIDTH: 0.907329
G1 F2858.404
G3 X137.527 Y123.653 I-.812 J.451 E.08794
; LINE_WIDTH: 0.876457
G1 F2975.089
G1 X137.508 Y124.661 E.17394
; LINE_WIDTH: 0.8233
M73 P84 R3
G1 F3200.008
G1 X137.489 Y125.669 E.16172
G1 X137.489 Y130.404 E.75965
; LINE_WIDTH: 0.840924
G1 F3121.763
G1 X137.51 Y131.052 E.10661
; LINE_WIDTH: 0.882777
G1 F2950.433
G1 X137.531 Y131.7 E.1128
; LINE_WIDTH: 0.92463
G1 F2796.93
G1 X137.552 Y132.348 E.11899
; LINE_WIDTH: 0.982733
G1 F2608.526
G1 X137.455 Y132.815 E.09392
G1 X137.334 Y133.049 E.0518
G1 X136.775 Y133.433 E.13352
G1 X135.851 Y133.719 E.19039
M204 S10000
G1 X138.143 Y130.404 F42000
; LINE_WIDTH: 0.752647
G1 F3557.481
M204 S6000
G1 X138.167 Y129.603 E.11567
; LINE_WIDTH: 0.800107
G1 F3309.164
G1 X138.191 Y128.801 E.12435
; LINE_WIDTH: 0.847567
G1 F3093.251
G1 X138.215 Y128 E.13303
; LINE_WIDTH: 0.848277
G1 F3090.235
G1 X138.193 Y127.263 E.12252
; LINE_WIDTH: 0.802237
G1 F3298.83
G1 X138.171 Y126.526 E.11478
; LINE_WIDTH: 0.756197
G1 F3537.625
M73 P84 R2
G1 X138.149 Y125.789 E.10703
; WIPE_START
G1 X138.171 Y126.526 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.513 Y133.387 Z21.52 F42000
G1 X142.705 Y135.834 Z21.52
G1 Z21.12
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.851947
G1 F3074.737
M204 S2000
G1 X143.343 Y135.197 E.15052
G1 X143.562 Y134.587 E.10812
G1 X143.708 Y133.797 E.13421
G1 X141.762 Y135.743 E.45948
G1 X140.752 Y135.905 E.17083
G1 X140.548 Y135.922 E.03418
G1 X143.943 Y132.527 E.80161
G1 X144.177 Y131.258 E.21557
G1 X140.524 Y134.911 E.86272
G1 X140.915 Y133.822 E.1932
G1 X140.992 Y133.409 E.07026
G1 X144.268 Y130.132 E.77372
G3 X144.332 Y129.034 I129.784 J6.92 E.18365
G1 X141.227 Y132.138 E.73297
G1 X141.463 Y130.867 E.21578
G1 X144.389 Y127.941 E.69096
G1 X144.331 Y126.964 E.16339
G1 X141.536 Y129.76 E.66005
G1 X141.601 Y128.659 E.184
G1 X144.275 Y125.986 E.63129
G1 X144.221 Y125.005 E.164
G1 X141.617 Y127.609 E.61476
G1 X141.559 Y126.632 E.1634
G1 X144.064 Y124.127 E.59146
G1 X143.903 Y123.253 E.14836
G1 X141.501 Y125.655 E.56712
G2 X141.375 Y124.747 I-3.03 J-.041 E.15371
G1 X143.722 Y122.399 E.5543
G1 X143.539 Y121.547 E.14548
G1 X141.192 Y123.894 E.55422
G1 X141.01 Y123.042 E.14552
G1 X143.299 Y120.753 E.54056
G2 X142.558 Y120.458 I-1.697 J3.193 E.13333
G1 X140.827 Y122.19 E.4088
G1 X140.644 Y121.338 E.14553
G1 X141.728 Y120.254 E.25587
G2 X140.838 Y120.109 I-3.246 J17.103 E.15054
G1 X140.111 Y120.836 E.17164
; WIPE_START
M204 S6000
G1 X140.838 Y120.109 E-.39065
G1 X141.35 Y120.18 E-.19631
G1 X141.728 Y120.254 E-.14639
G1 X141.678 Y120.303 E-.02665
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.804 Y123.62 Z21.52 F42000
G1 X112.209 Y134.52 Z21.52
G1 Z21.12
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.421 Y132.383 I5.578 J-6.484 E.44688
G1 X122.192 Y120.612 E2.65804
G2 X119.605 Y119.605 I-4.854 J8.642 E.44482
G1 X131.708 Y131.708 E2.73305
G1 X131.708 Y124.292 E1.18406
G1 X119.605 Y136.395 E2.73308
G2 X122.194 Y135.389 I-2.288 J-9.724 E.44495
G1 X110.424 Y123.62 E2.65769
G3 X112.211 Y121.483 I7.616 J4.552 E.44666
; CHANGE_LAYER
; Z_HEIGHT: 21.68
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.448 Y122.219 E-.40284
G1 X110.918 Y122.863 E-.31708
G1 X110.86 Y122.952 E-.04008
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 39/51
; update layer progress
M73 L39
M991 S0 P38 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z21.68 I.311 J1.675 P1  F42000
G1 X123.585 Y120.586 Z21.68
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.676 Y120.607 E.01486
G2 X124.746 Y120.76 I1.166 J-4.348 E.17301
G1 X136.164 Y120.76 E1.82307
G1 X137.019 Y120.773 E.13659
G1 X137.278 Y121.615 E.14063
G1 X137.426 Y121.881 E.04863
G1 X137.963 Y124.381 E.40827
G1 X138.188 Y125.117 E.12296
G1 X138.268 Y125.563 E.07234
G1 X138.412 Y128 E.3898
G1 X138.268 Y130.437 E.38981
G3 X137.808 Y132.933 I-220.259 J-39.268 E.4053
G1 X137.144 Y134.783 E.31382
G1 X136.931 Y135.229 E.07892
G1 X124.746 Y135.241 E1.94564
G2 X122.768 Y135.746 I.095 J4.499 E.32887
G3 X118.21 Y118.82 I-4.949 J-7.744 E5.50692
G3 X122.764 Y120.253 I-.505 J9.558 E.77043
G2 X123.149 Y120.431 I2.077 J-3.994 E.06768
G1 X123.472 Y120.546 E.05482
M204 S10000
G1 X123.807 Y119.923 F42000
G1 F3215.099
M204 S6000
G1 X123.854 Y119.932 E.0077
G2 X124.755 Y120.06 I.976 J-3.627 E.14566
G1 X136.169 Y120.06 E1.8226
G3 X137.544 Y120.1 I.114 J19.641 E.21959
G1 X137.926 Y121.339 E.20702
G1 X138.088 Y121.633 E.05359
G1 X138.641 Y124.205 E.42007
G1 X138.869 Y124.953 E.12485
G1 X138.964 Y125.48 E.08559
G1 X139.113 Y128 E.40306
G1 X138.964 Y130.52 E.40307
G3 X138.486 Y133.117 I-229.368 J-40.885 E.42159
G1 X137.791 Y135.053 E.32845
G1 X137.381 Y135.911 E.15182
G3 X136.17 Y135.94 I-1.256 J-26.725 E.19353
G1 X124.755 Y135.94 E1.82267
G2 X123.101 Y136.361 I.075 J3.755 E.27491
G3 X118.243 Y118.121 I-5.289 J-8.359 E5.92151
G3 X123.099 Y119.638 I-.542 J10.264 E.82083
G2 X123.415 Y119.784 I1.732 J-3.333 E.05558
G1 X123.694 Y119.883 E.04728
M204 S250
G1 X123.854 Y119.201 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.032 Y119.256 E.02978
G2 X124.764 Y119.36 I.787 J-2.906 E.11831
G1 X136.175 Y119.36 E1.82213
G3 X140.405 Y119.798 I.308 J17.694 E.68068
G3 X141.555 Y120.219 I-1.426 J5.663 E.19585
G1 X141.785 Y120.392 E.04592
G2 X141.979 Y120.813 I1.148 J-.272 E.07457
G1 X142.881 Y125.025 E.68773
G1 X143.058 Y128 E.47597
G1 X142.881 Y130.982 E.47688
G1 X142.285 Y134.193 E.52154
G1 X141.808 Y135.522 E.22541
G3 X141.746 Y135.656 I-.101 J.035 E.02604
G3 X140.405 Y136.204 I-2.271 J-3.639 E.23239
G3 X136.176 Y136.64 I-3.895 J-17.037 E.68066
G1 X124.764 Y136.64 E1.82218
G2 X123.434 Y136.977 I.055 J3.01 E.22097
G3 X118.276 Y117.422 I-5.622 J-8.975 E6.33315
G3 X123.433 Y119.023 I-.579 J10.972 E.87122
G2 X123.68 Y119.137 I1.386 J-2.673 E.04348
G1 X123.741 Y119.16 E.0104
; WIPE_START
M204 S6000
G1 X124.032 Y119.256 E-.11643
G1 X124.396 Y119.336 E-.14164
G1 X124.764 Y119.36 E-.13997
G1 X125.716 Y119.36 E-.36196
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
            G0 Z22.08 F4000
            G39.3 S1
            G0 Z22.08 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X112.212 Y121.481 F42000
G1 Z21.68
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G2 X110.418 Y123.614 I6.109 J6.961 E.4467
G1 X122.194 Y135.39 E2.65909
G3 X119.593 Y136.407 I-4.433 J-7.501 E.44774
G1 X131.379 Y124.621 E2.66129
G1 X131.379 Y131.379 E1.07899
G1 X119.605 Y119.605 E2.65874
G3 X122.192 Y120.612 I-2.271 J9.661 E.4448
G1 X110.421 Y132.383 E2.658
G2 X112.211 Y134.518 I8.628 J-5.411 E.44627
M204 S10000
G1 X132.649 Y133.966 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.822037
G1 F1800
M204 S6000
G1 X134.296 Y133.966 E.26388
G2 X136.215 Y133.264 I-.042 J-3.086 E.33342
G1 X132.079 Y133.264 E.66237
G1 X132.079 Y132.562 E.1124
G1 X136.916 Y132.562 E.7747
G1 X137.12 Y132.191 E.06785
G1 X137.25 Y131.861 E.05682
G1 X132.079 Y131.861 E.82807
G1 X132.079 Y131.159 E.1124
G1 X137.439 Y131.159 E.8584
G1 X137.478 Y130.788 E.05964
G2 X137.479 Y130.457 I-8.507 J-.176 E.05309
G1 X132.079 Y130.457 E.86477
G1 X132.079 Y129.755 E.1124
M73 P85 R2
G1 X137.479 Y129.755 E.86477
G1 X137.479 Y129.053 E.1124
G1 X132.079 Y129.053 E.86477
G1 X132.079 Y128.351 E.1124
G1 X137.479 Y128.351 E.86477
G1 X137.479 Y127.649 E.1124
G1 X132.079 Y127.649 E.86477
G1 X132.079 Y126.947 E.1124
G1 X137.479 Y126.947 E.86477
G1 X137.479 Y126.246 E.1124
G1 X132.079 Y126.246 E.86477
G1 X132.079 Y125.544 E.1124
G1 X137.479 Y125.544 E.86477
G2 X137.439 Y124.842 I-3.168 J-.173 E.11281
G1 X132.079 Y124.842 E.8584
G1 X132.079 Y124.14 E.1124
G1 X137.25 Y124.14 E.82807
G1 X137.12 Y123.81 E.05683
G1 X136.916 Y123.438 E.06784
G1 X132.079 Y123.438 E.77471
G1 X132.079 Y122.736 E.1124
G1 X136.215 Y122.736 E.66238
G2 X134.298 Y122.034 I-1.96 J2.384 E.33318
G1 X132.648 Y122.034 E.26416
M106 S196.35
; WIPE_START
G1 X134.298 Y122.034 E-.62684
G1 X134.647 Y122.063 E-.13316
; WIPE_END
G1 E-.04
M204 S10000
G1 X139.467 Y119.891 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.823297
G1 F3200.023
M204 S2000
G1 X141.638 Y122.061 E.49249
G1 X141.909 Y123.327 E.20764
G1 X138.675 Y120.092 E.73387
G2 X138.148 Y120.04 I-.859 J5.924 E.08501
G1 X138.379 Y120.791 E.12619
G1 X142.181 Y124.592 E.86242
G1 X142.29 Y125.105 E.0841
G1 X142.328 Y125.734 E.10107
G1 X138.825 Y122.232 E.79461
G1 X139.097 Y123.498 E.2078
G1 X142.39 Y126.791 E.74711
G1 X142.453 Y127.848 E.16987
G1 X139.455 Y124.85 E.68016
G3 X139.589 Y125.979 I-4.67 J1.128 E.18279
G1 X142.414 Y128.804 E.64091
G1 X142.359 Y129.742 E.15086
G1 X139.652 Y127.036 E.61405
G1 X139.704 Y128.083 E.16813
G1 X142.303 Y130.681 E.58955
G1 X142.29 Y130.909 E.03667
G1 X142.172 Y131.544 E.10358
G1 X139.649 Y129.021 E.5724
G1 X139.593 Y129.96 E.15085
G1 X142.016 Y132.383 E.54973
G1 X141.86 Y133.222 E.13685
G1 X139.506 Y130.867 E.53418
G3 X139.352 Y131.708 I-74.451 J-13.165 E.13712
G1 X141.702 Y134.057 E.53304
G1 X141.439 Y134.789 E.12471
G1 X139.197 Y132.547 E.50874
G1 X139.062 Y133.273 E.11843
G1 X139.027 Y133.371 E.01679
G1 X141.024 Y135.369 E.45321
G3 X140.282 Y135.62 I-1.535 J-3.307 E.12605
G1 X138.764 Y134.103 E.34432
G1 X138.501 Y134.834 E.12471
G1 X139.46 Y135.793 E.21756
G3 X138.592 Y135.92 I-2.055 J-11.055 E.14073
G1 X137.98 Y135.307 E.13901
; WIPE_START
M204 S6000
G1 X138.592 Y135.92 E-.32927
G1 X139.46 Y135.793 E-.33326
G1 X139.279 Y135.612 E-.09748
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.096 Y134.523 Z22.08 F42000
G1 Z21.68
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.807788
G1 F3272.198
M204 S6000
G2 X135.016 Y134.561 I1.143 J-9.302 E.30173
; LINE_WIDTH: 0.82005
G1 F3214.871
G1 X135.182 Y134.536 E.02685
; LINE_WIDTH: 0.859794
G1 F3042.113
G1 X135.348 Y134.511 E.02838
; LINE_WIDTH: 0.89954
G1 F2886.975
G1 X135.515 Y134.486 E.0299
; LINE_WIDTH: 0.939285
G1 F2746.892
G1 X135.681 Y134.461 E.03143
; LINE_WIDTH: 0.983822
G1 F2605.237
G1 X135.77 Y134.44 E.01808
; LINE_WIDTH: 1.03315
G1 F2464.471
G1 X135.86 Y134.419 E.01911
; LINE_WIDTH: 1.08248
G1 F2338.136
G1 X135.949 Y134.397 E.02015
; LINE_WIDTH: 1.13181
G1 F2224.122
G1 X136.038 Y134.376 E.02118
; LINE_WIDTH: 1.18114
G1 F2120.711
G1 X136.127 Y134.355 E.02221
; LINE_WIDTH: 1.23047
G1 F2026.488
G1 X136.217 Y134.334 E.02325
; WIPE_START
G1 X136.127 Y134.355 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.384 Y126.924 Z22.08 F42000
G1 X133.105 Y121.472 Z22.08
G1 Z21.68
G1 E.8 F1800
; LINE_WIDTH: 0.813013
G1 F3247.523
M204 S6000
G3 X134.592 Y121.408 I1.104 J8.337 E.23563
M204 S10000
G1 X134.712 Y121.411 F42000
; LINE_WIDTH: 0.77545
G1 F3433.686
M204 S6000
G1 X134.975 Y121.467 E.04021
; LINE_WIDTH: 0.702696
G1 F3862.533
G1 X135.238 Y121.524 E.03575
G3 X136.281 Y122 I-1.029 J3.634 E.15291
M73 P86 R2
G1 X136.896 Y122.466 E.10263
G2 X136.638 Y121.71 I-1.999 J.262 E.10686
G1 X136.544 Y121.406 E.0423
G2 X135.202 Y121.4 I-1.002 J74.713 E.1783
; LINE_WIDTH: 0.725995
G1 F3713.99
G1 X135.017 Y121.404 E.02558
; LINE_WIDTH: 0.77545
G1 F3433.686
G1 X134.832 Y121.408 E.02767
; CHANGE_LAYER
; Z_HEIGHT: 22.24
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3433.686
G1 X135.017 Y121.404 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 40/51
; update layer progress
M73 L40
M991 S0 P39 ;notify layer change
M106 S198.9
; OBJECT_ID: 15
M204 S10000
G17
G3 Z22.24 I.117 J-1.7 P1  F42000
G1 X123.728 Y120.625 Z22.24
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X124.165 Y120.716 E.07115
G2 X124.747 Y120.76 I.61 J-4.197 E.09325
G1 X134.882 Y120.772 E1.61838
G1 X135.15 Y121.36 E.10322
G1 X135.226 Y121.605 E.04088
G1 X135.438 Y121.988 E.06992
G1 X135.644 Y122.948 E.15686
G1 X136.119 Y124.503 E.25963
G1 X136.35 Y125.792 E.209
G1 X136.481 Y128 E.35327
G1 X136.35 Y130.209 E.35327
G3 X135.955 Y132.384 I-192.196 J-33.789 E.35295
G1 X135.129 Y134.683 E.3902
G1 X134.869 Y135.23 E.09659
G1 X124.747 Y135.241 E1.61629
G2 X122.768 Y135.746 I.028 J4.24 E.32936
G3 X118.219 Y118.82 I-4.948 J-7.744 E5.50833
G3 X122.764 Y120.252 I-.449 J9.35 E.76922
G2 X123.612 Y120.597 I2.012 J-3.734 E.1465
M204 S10000
G1 X123.877 Y119.943 F42000
G1 F3215.099
M204 S6000
G1 X124.269 Y120.024 E.06389
G2 X124.755 Y120.06 I.506 J-3.5 E.0779
G1 X134.12 Y120.06 E1.49537
G3 X135.342 Y120.093 I.141 J17.289 E.19524
G1 X135.806 Y121.111 E.17853
G1 X135.873 Y121.329 E.0365
G1 X136.1 Y121.74 E.07489
G1 X136.322 Y122.772 E.16866
G1 X136.8 Y124.339 E.26153
G1 X137.046 Y125.709 E.22225
G1 X137.182 Y128 E.36654
G1 X137.046 Y130.292 E.36653
G3 X136.633 Y132.567 I-200.712 J-35.297 E.36925
G1 X135.776 Y134.953 E.40483
G1 X135.322 Y135.905 E.16847
G3 X134.121 Y135.94 I-1.033 J-14.826 E.19195
G1 X124.755 Y135.94 E1.49547
G2 X123.101 Y136.362 I.019 J3.535 E.27529
G3 X118.252 Y118.121 I-5.288 J-8.359 E5.92285
G3 X123.098 Y119.638 I-.48 J10.035 E.81969
G2 X123.761 Y119.912 I1.676 J-3.114 E.11473
M204 S250
G1 X123.874 Y119.208 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.023 Y119.259 E.02511
G2 X124.764 Y119.36 I.751 J-2.731 E.11973
G1 X134.126 Y119.36 E1.49492
G3 X138.015 Y119.716 I.179 J19.488 E.62467
G1 X138.721 Y119.898 E.11638
G3 X139.5 Y120.21 I-3.175 J9.076 E.13404
G1 X139.736 Y120.388 E.04715
G1 X139.785 Y120.548 E.02672
G1 X139.991 Y120.92 E.06786
G1 X140.588 Y123.7 E.45397
G1 X140.826 Y124.48 E.13029
G1 X140.963 Y125.242 E.12368
G1 X141.127 Y128 E.44115
G1 X140.963 Y130.758 E.44115
G3 X140.432 Y133.643 I-254.35 J-45.308 E.46839
G1 X139.754 Y135.532 E.32043
G3 X139.727 Y135.639 I-.094 J.034 E.01865
G3 X139.007 Y136.001 I-1.551 J-2.187 E.12926
G3 X136.38 Y136.534 I-3.56 J-10.809 E.42903
G3 X134.126 Y136.64 I-2.341 J-25.748 E.36033
G1 X124.764 Y136.64 E1.49498
G2 X123.434 Y136.977 I.01 J2.832 E.22127
G3 X118.285 Y117.422 I-5.622 J-8.975 E6.33456
G3 X123.433 Y119.023 I-.511 J10.721 E.87012
G2 X123.674 Y119.138 I1.341 J-2.494 E.04267
G1 X123.761 Y119.168 E.01472
; WIPE_START
M204 S6000
G1 X124.023 Y119.259 E-.10535
G1 X124.373 Y119.332 E-.13585
G1 X124.764 Y119.36 E-.1489
G1 X125.737 Y119.36 E-.3699
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


G1 X134.427 Y134.53 F42000
G1 Z22.24
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G2 X135.277 Y132.202 I-101.596 J-38.404 E.3958
G1 X135.654 Y130.125 E.33697
G1 X135.774 Y127.896 E.35646
G1 X135.654 Y125.874 E.32336
G1 X135.437 Y124.668 E.1957
G1 X134.97 Y123.138 E.25539
G3 X134.775 Y122.236 I261.216 J-56.952 E.14741
G3 X134.419 Y121.471 I2.92 J-1.826 E.13512
G1 X131.043 Y121.467 E.53892
G1 X132.164 Y124.571 E.52694
G1 X132.258 Y125.08 E.08257
G1 X132.26 Y130.888 E.92741
G1 X132.171 Y131.402 E.08341
G1 X131.029 Y134.534 E.53222
G1 X134.307 Y134.53 E.52341
M204 S10000
G1 X135.076 Y128.063 F42000
G1 F3215.112
M204 S6000
G1 X134.958 Y125.957 E.33673
G1 X134.756 Y124.833 E.18243
G1 X134.301 Y123.343 E.24876
G1 X134.128 Y122.555 E.1288
G1 X133.945 Y122.17 E.06798
G1 X132.05 Y122.168 E.30262
G1 X132.823 Y124.336 E.36751
G1 X132.94 Y124.896 E.09134
G1 X132.958 Y126.077 E.18855
G1 X132.96 Y130.887 E.76817
G1 X132.876 Y131.464 E.09302
G1 X132.829 Y131.641 E.02933
G1 X132.035 Y133.833 E.37216
G1 X133.948 Y133.831 E.30545
G1 X134.599 Y132.02 E.3073
G1 X134.958 Y130.042 E.32099
G1 X135.068 Y128.183 E.29735
M204 S10000
G1 X134.372 Y128.021 F42000
; LINE_WIDTH: 0.829427
G1 F3172.365
M204 S6000
G1 X134.372 Y127.979 E.0068
; LINE_WIDTH: 0.815267
G1 F3236.991
G1 X134.329 Y127.018 E.15259
; LINE_WIDTH: 0.7864
G1 F3377.249
G1 X134.282 Y126.018 E.15212
; LINE_WIDTH: 0.796094
G1 F3328.811
G1 X134.242 Y125.925 E.01569
; LINE_WIDTH: 0.842708
G1 F3114.053
G1 X134.201 Y125.832 E.01677
; LINE_WIDTH: 0.889322
G1 F2925.326
G1 X134.161 Y125.738 E.01785
; LINE_WIDTH: 0.935936
G1 F2758.168
G1 X134.12 Y125.645 E.01894
; LINE_WIDTH: 0.98255
G1 F2609.08
G1 X134.08 Y125.552 E.02002
; LINE_WIDTH: 1.02916
G1 F2475.283
G1 X134.039 Y125.458 E.0211
; LINE_WIDTH: 1.07578
G1 F2354.539
G1 X133.999 Y125.365 E.02218
; LINE_WIDTH: 1.12239
G1 F2245.027
G1 X133.958 Y125.272 E.02327
; LINE_WIDTH: 1.16901
G1 F2145.25
G1 X133.918 Y125.178 E.02435
; LINE_WIDTH: 1.21775
G1 F2049.986
G1 X133.867 Y125.086 E.0264
; LINE_WIDTH: 1.21562
G1 F2053.964
G1 X133.844 Y125.185 E.02543
; LINE_WIDTH: 1.16901
G1 F2145.25
G1 X133.821 Y125.284 E.02435
; LINE_WIDTH: 1.12239
G1 F2245.027
G1 X133.797 Y125.383 E.02327
; LINE_WIDTH: 1.07578
G1 F2354.539
G1 X133.774 Y125.482 E.02218
; LINE_WIDTH: 1.02916
G1 F2475.283
G1 X133.751 Y125.581 E.0211
; LINE_WIDTH: 0.98255
G1 F2609.08
G1 X133.728 Y125.68 E.02002
; LINE_WIDTH: 0.935936
G1 F2758.168
G1 X133.704 Y125.779 E.01894
; LINE_WIDTH: 0.889322
G1 F2925.326
G1 X133.681 Y125.878 E.01786
; LINE_WIDTH: 0.842708
G1 F3114.053
G1 X133.658 Y125.977 E.01677
; LINE_WIDTH: 0.800855
G1 F3305.527
G1 X133.635 Y126.076 E.0158
G1 X133.664 Y128 E.29885
; LINE_WIDTH: 0.81509
G1 F3237.818
G1 X133.65 Y128.961 E.15237
; LINE_WIDTH: 0.786415
G1 F3377.174
G1 X133.636 Y129.922 E.14609
; LINE_WIDTH: 0.79596
G1 F3329.471
G1 X133.66 Y130.019 E.01533
; LINE_WIDTH: 0.843726
G1 F3109.672
G1 X133.684 Y130.115 E.01641
; LINE_WIDTH: 0.891492
G1 F2917.096
G1 X133.707 Y130.212 E.01749
; LINE_WIDTH: 0.939258
G1 F2746.981
G1 X133.731 Y130.308 E.01858
; LINE_WIDTH: 0.987024
G1 F2595.614
G1 X133.755 Y130.405 E.01966
; LINE_WIDTH: 1.03479
G1 F2460.057
G1 X133.779 Y130.501 E.02074
; LINE_WIDTH: 1.08256
G1 F2337.956
M73 P87 R2
G1 X133.803 Y130.598 E.02183
; LINE_WIDTH: 1.13032
G1 F2227.403
G1 X133.827 Y130.694 E.02291
; LINE_WIDTH: 1.17809
G1 F2126.833
G1 X133.851 Y130.791 E.024
; LINE_WIDTH: 1.22585
G1 F2034.952
G1 X133.875 Y130.887 E.02508
G1 X133.916 Y130.796 E.02508
; LINE_WIDTH: 1.17809
G1 F2126.833
G1 X133.956 Y130.706 E.02399
; LINE_WIDTH: 1.13032
G1 F2227.403
G1 X133.997 Y130.615 E.02291
; LINE_WIDTH: 1.08256
G1 F2337.956
G1 X134.038 Y130.524 E.02183
; LINE_WIDTH: 1.03479
G1 F2460.057
G1 X134.079 Y130.434 E.02074
; LINE_WIDTH: 0.987024
G1 F2595.614
G1 X134.119 Y130.343 E.01966
; LINE_WIDTH: 0.939258
G1 F2746.981
G1 X134.16 Y130.252 E.01858
; LINE_WIDTH: 0.891492
G1 F2917.096
G1 X134.201 Y130.162 E.0175
; LINE_WIDTH: 0.843726
G1 F3109.672
G1 X134.242 Y130.071 E.01641
; LINE_WIDTH: 0.789202
G1 F3363.104
G2 X134.287 Y129.941 I-.185 J-.137 E.02129
; LINE_WIDTH: 0.786415
G1 F3377.174
G1 X134.327 Y129.041 E.13697
; LINE_WIDTH: 0.81509
G1 F3237.818
G1 X134.367 Y128.141 E.14286
M204 S10000
G1 X133.316 Y132.933 F42000
; LINE_WIDTH: 1.21772
G1 F2050.039
M204 S6000
G1 X133.672 Y131.947 E.26264
G2 X133.859 Y131.006 I-5.617 J-1.606 E.24045
M204 S10000
G1 X133.321 Y123.065 F42000
; LINE_WIDTH: 1.1956
G1 F2092.206
M204 S6000
G1 X133.398 Y123.33 E.06767
; LINE_WIDTH: 1.16292
G1 F2157.777
G1 X133.475 Y123.595 E.06561
; LINE_WIDTH: 1.14343
G1 F2198.879
G3 X133.806 Y124.736 I-8.174 J2.986 E.27756
; LINE_WIDTH: 1.19753
G1 F2088.458
G1 X133.828 Y124.848 E.0281
; LINE_WIDTH: 1.23107
G1 F2025.403
G1 X133.849 Y124.96 E.02897
; WIPE_START
G1 X133.828 Y124.848 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.419 Y130.945 Z22.64 F42000
G1 X140.208 Y133.319 Z22.64
G1 Z22.24
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.823027
G1 F3201.252
M204 S2000
G1 X137.809 Y135.717 E.54392
G1 X137.7 Y135.735 E.01772
G3 X136.628 Y135.905 I-2.27 J-10.81 E.17424
G1 X140.041 Y132.492 E.77411
G2 X140.266 Y131.273 I-107.956 J-20.58 E.19885
G1 X136.298 Y135.241 E.90004
G1 X136.866 Y133.679 E.2665
G1 X140.404 Y130.141 E.80246
G1 X140.467 Y129.084 E.16975
G1 X137.296 Y132.255 E.71908
G2 X137.516 Y131.041 I-107.198 J-20.074 E.19791
G1 X140.529 Y128.028 E.68334
G1 X140.477 Y127.086 E.1512
G1 X137.666 Y129.897 E.6375
G1 X137.728 Y128.841 E.16975
G1 X140.421 Y126.148 E.61064
G1 X140.355 Y125.22 E.14916
G1 X137.767 Y127.808 E.5869
G1 X137.711 Y126.87 E.15073
G1 X140.18 Y124.401 E.5599
G3 X139.963 Y123.624 I4.461 J-1.664 E.12954
G1 X137.656 Y125.932 E.52334
G2 X137.534 Y125.059 I-3.723 J.074 E.1416
G1 X139.787 Y122.806 E.51103
G1 X139.612 Y121.987 E.13421
G1 X137.383 Y124.216 E.50552
G1 X137.152 Y123.453 E.12786
G1 X139.436 Y121.169 E.51801
G1 X139.22 Y120.735 E.07772
G2 X138.984 Y120.628 I-1.79 J3.615 E.04169
G1 X136.919 Y122.692 E.46818
G1 X136.738 Y121.879 E.13357
G1 X138.231 Y120.386 E.33855
G2 X137.408 Y120.215 I-1.767 J6.437 E.13488
G1 X136.461 Y121.163 E.21491
G2 X136.165 Y120.464 I-20.609 J8.319 E.12161
G1 X136.826 Y119.803 E.15
; WIPE_START
M204 S6000
G1 X136.165 Y120.464 E-.35545
G1 X136.363 Y120.899 E-.1815
G1 X136.461 Y121.163 E-.10682
G1 X136.677 Y120.946 E-.11624
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.002 Y124.648 Z22.64 F42000
G1 X112.217 Y134.513 Z22.64
G1 Z22.24
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.419 Y132.385 I5.376 J-6.367 E.44692
G1 X122.192 Y120.612 E2.65861
G2 X119.604 Y119.604 I-4.869 J8.679 E.44485
G1 X131.422 Y131.422 E2.66854
G2 X131.561 Y130.87 I-1.537 J-.68 E.09133
G1 X131.561 Y125.131 E.91641
G2 X131.423 Y124.577 I-1.735 J.136 E.09154
G1 X119.605 Y136.395 E2.66878
G2 X122.197 Y135.393 I-1.747 J-8.366 E.44569
G1 X110.418 Y123.614 E2.65973
G3 X112.215 Y121.484 I8.644 J5.468 E.44628
; CHANGE_LAYER
; Z_HEIGHT: 22.8
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.157 Y122.557 E-.57241
G1 X110.874 Y122.961 E-.18759
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 41/51
; update layer progress
M73 L41
M991 S0 P40 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z22.8 I.305 J1.676 P1  F42000
G1 X123.728 Y120.625 Z22.8
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.167 Y120.716 E.07153
G2 X124.747 Y120.76 I.609 J-4.197 E.09302
G1 X131.922 Y120.76 E1.14564
G1 X132.818 Y120.777 E.14307
G1 X133.119 Y121.421 E.1135
G1 X133.173 Y121.595 E.02902
G1 X133.466 Y122.124 E.09666
G1 X134.096 Y124.145 E.33797
G1 X134.433 Y126.02 E.30418
G1 X134.55 Y128 E.31674
G1 X134.433 Y129.98 E.31674
G1 X134.095 Y131.858 E.30454
G1 X133.124 Y134.559 E.45839
G1 X132.795 Y135.231 E.11952
G2 X131.925 Y135.241 I-.302 J12.517 E.13893
G1 X124.747 Y135.241 E1.14615
G2 X122.767 Y135.746 I.028 J4.239 E.32951
G3 X118.229 Y118.821 I-4.954 J-7.743 E5.51267
G3 X122.763 Y120.252 I-.46 J9.354 E.76766
G2 X123.611 Y120.597 I2.012 J-3.733 E.14647
M204 S10000
G1 X123.876 Y119.943 F42000
G1 F3215.099
M204 S6000
G1 X124.271 Y120.024 E.06426
G2 X124.755 Y120.06 I.504 J-3.5 E.0777
G1 X131.929 Y120.06 E1.14543
G3 X133.27 Y120.094 I.201 J18.5 E.21433
G1 X133.774 Y121.168 E.18941
G1 X133.82 Y121.319 E.02522
G1 X134.114 Y121.85 E.09681
G1 X134.677 Y123.693 E.30772
G1 X134.774 Y123.963 E.04587
G1 X135.129 Y125.937 E.32026
G1 X135.251 Y128 E.33
G1 X135.129 Y130.063 E.33
G1 X134.774 Y132.039 E.32055
G1 X133.769 Y134.832 E.4739
G1 X133.245 Y135.905 E.19065
G3 X131.931 Y135.94 I-2.031 J-50.271 E.20986
G1 X124.755 Y135.94 E1.14576
G2 X123.1 Y136.362 I.019 J3.535 E.27541
G3 X118.262 Y118.121 I-5.288 J-8.359 E5.92449
G3 X123.098 Y119.638 I-.492 J10.039 E.81808
G2 X123.761 Y119.912 I1.676 J-3.114 E.11468
M204 S250
G1 X123.99 Y119.248 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.023 Y119.259 E.00564
G2 X124.764 Y119.36 I.75 J-2.731 E.11968
G1 X131.936 Y119.36 E1.14521
G3 X135.978 Y119.724 I.223 J20.16 E.64915
G3 X137.363 Y120.168 I-1.838 J8.117 E.23245
G3 X137.688 Y120.395 I-.605 J1.21 E.06361
G1 X137.732 Y120.538 E.02388
G1 X138.002 Y121.027 E.08914
G1 X138.269 Y122.267 E.20256
G1 X138.757 Y123.866 E.26696
G1 X139.046 Y125.471 E.26035
G1 X139.196 Y128 E.40462
G1 X139.046 Y130.53 E.40462
G3 X138.579 Y133.093 I-226.002 J-39.779 E.41605
G1 X137.7 Y135.542 E.41545
G3 X137.682 Y135.625 I-.109 J.02 E.01382
G3 X136.674 Y136.097 I-1.739 J-2.398 E.17891
G3 X133.044 Y136.619 I-4.017 J-15.067 E.58687
G2 X131.937 Y136.64 I1.052 J82.027 E.17683
G1 X124.764 Y136.64 E1.14537
G2 X123.434 Y136.977 I.01 J2.832 E.2213
G3 X118.295 Y117.422 I-5.622 J-8.975 E6.33619
G3 X123.433 Y119.023 I-.523 J10.726 E.86848
G2 X123.673 Y119.138 I1.341 J-2.494 E.04252
G1 X123.876 Y119.209 E.03442
; WIPE_START
M204 S6000
G1 X124.023 Y119.259 E-.05902
G1 X124.374 Y119.333 E-.13634
G1 X124.764 Y119.36 E-.14831
G1 X125.859 Y119.36 E-.41633
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


G1 X138.093 Y122.65 F42000
G1 Z22.8
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.822027
G1 F3205.813
M204 S2000
G1 X135.729 Y120.286 E.53546
G2 X134.544 Y120.093 I-3.431 J17.351 E.19235
G1 X138.056 Y123.605 E.79537
G1 X138.178 Y124.006 E.06709
G1 X138.335 Y124.877 E.14167
G1 X134.258 Y120.8 E.92322
G2 X134.664 Y121.616 I4.888 J-1.925 E.14619
G1 X134.921 Y122.455 E.14052
G1 X138.482 Y126.017 E.80657
G1 X138.545 Y127.072 E.16927
G1 X135.366 Y123.893 E.71989
G1 X135.584 Y125.103 E.19688
G1 X138.593 Y128.113 E.6816
G1 X138.538 Y129.05 E.1503
G1 X135.744 Y126.256 E.6327
G1 X135.806 Y127.311 E.16927
G1 X138.482 Y129.987 E.60593
G3 X138.379 Y130.877 I-3.786 J.012 E.14374
G1 X135.828 Y128.326 E.57771
G1 X135.772 Y129.263 E.15031
G1 X138.228 Y131.718 E.55606
G3 X138.074 Y132.557 I-73.906 J-13.112 E.13657
G1 X135.71 Y130.193 E.53535
G1 X135.559 Y131.034 E.13689
G1 X137.86 Y133.336 E.52121
G1 X137.598 Y134.066 E.12426
G1 X135.408 Y131.876 E.49606
G1 X135.351 Y132.193 E.05171
G1 X135.187 Y132.648 E.0773
G1 X137.336 Y134.796 E.4866
G1 X137.168 Y135.262 E.0793
G3 X136.926 Y135.379 I-.647 J-1.039 E.04321
G1 X134.925 Y133.378 E.45317
G1 X134.662 Y134.108 E.12423
G1 X136.168 Y135.614 E.34108
G3 X135.348 Y135.786 I-2.186 J-8.366 E.13427
G1 X134.399 Y134.837 E.21479
G3 X134.093 Y135.524 I-3.277 J-1.051 E.12059
G1 X134.76 Y136.191 E.15112
; WIPE_START
M204 S6000
G1 X134.093 Y135.524 E-.35859
G1 X134.318 Y135.064 E-.19452
G1 X134.399 Y134.837 E-.09143
G1 X134.614 Y135.052 E-.11545
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.358 Y134.532 Z23.2 F42000
G1 Z22.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G2 X133.417 Y131.676 I-53.444 J-21.445 E.48646
G1 X133.737 Y129.898 E.2885
G1 X133.844 Y128.095 E.28833
G1 X133.737 Y126.103 E.31855
G1 X133.415 Y124.312 E.29057
G1 X132.819 Y122.401 E.3196
G3 X132.359 Y121.468 I4.242 J-2.674 E.16637
G2 X128.791 Y121.46 I-2.067 J116.232 E.56961
G1 X129.29 Y122.268 E.15155
G1 X129.504 Y122.743 E.08322
G2 X130.287 Y125.024 I27.277 J-8.086 E.38517
G1 X130.551 Y126.453 E.23207
G1 X130.644 Y127.971 E.24285
G1 X130.553 Y129.53 E.24944
G1 X130.294 Y130.949 E.23033
G1 X129.711 Y132.559 E.27334
G1 X129.493 Y133.271 E.11895
G1 X129.287 Y133.739 E.08155
G1 X128.796 Y134.536 E.14953
G1 X132.238 Y134.532 E.54956
M204 S10000
G1 X131.897 Y133.833 F42000
G1 F3215.112
M204 S6000
G1 X132.739 Y131.494 E.39681
G1 X133.041 Y129.815 E.27249
G1 X133.145 Y128.054 E.28169
G2 X133.041 Y126.186 I-34.315 J.983 E.29874
G1 X132.734 Y124.479 E.27698
G1 X132.172 Y122.677 E.30124
G1 X131.891 Y122.16 E.09411
G1 X130.011 Y122.159 E.30022
G1 X130.188 Y122.577 E.07238
G1 X130.417 Y123.324 E.12477
G1 X130.945 Y124.786 E.24821
G1 X130.99 Y124.955 E.028
G1 X131.254 Y126.452 E.24265
G1 X131.343 Y127.929 E.23636
G1 X131.256 Y129.531 E.25609
G1 X130.998 Y131.016 E.24069
G1 X130.952 Y131.188 E.0284
G1 X130.375 Y132.78 E.27049
G3 X130.013 Y133.835 I-5.557 J-1.318 E.1783
G1 X131.777 Y133.833 E.28178
M204 S10000
G1 X131.325 Y123.092 F42000
; LINE_WIDTH: 1.26917
G1 F1958.233
M204 S6000
G1 X131.558 Y123.786 E.19197
; LINE_WIDTH: 1.21841
G1 F2048.741
G3 X131.876 Y124.795 I-8.033 J3.087 E.26516
G1 X132.152 Y126.398 E.40765
M73 P88 R2
G1 X132.24 Y127.876 E.37107
G1 X132.241 Y128.106 E.05751
G1 X132.154 Y129.584 E.37112
G1 X132.127 Y129.812 E.05752
G1 X131.883 Y131.175 E.34695
G1 X131.791 Y131.492 E.08263
G1 X131.309 Y132.826 E.35552
M204 S10000
G1 X112.211 Y121.48 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G2 X110.419 Y123.615 I7.322 J7.967 E.44625
G1 X122.194 Y135.39 E2.65888
G3 X119.605 Y136.395 I-4.286 J-7.2 E.44546
G1 X129.795 Y126.205 E2.30108
G3 X129.86 Y129.436 I-13.484 J1.886 E.51725
G1 X129.795 Y129.795 E.0583
G1 X119.604 Y119.604 E2.30123
G3 X122.192 Y120.612 I-2.287 J9.701 E.44483
G1 X110.422 Y132.382 E2.65782
G2 X112.216 Y134.512 I7.574 J-4.556 E.44656
; CHANGE_LAYER
; Z_HEIGHT: 23.36
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3215.099
G1 X111.274 Y133.583 E-.50259
G1 X110.883 Y133.031 E-.25741
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 42/51
; update layer progress
M73 L42
M991 S0 P41 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z23.36 I1.191 J1.218 P1  F42000
G1 X123.602 Y120.59 Z23.36
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.69 Y120.61 E.0144
G2 X124.747 Y120.76 I1.156 J-4.369 E.17091
G1 X129.562 Y120.76 E.76881
G3 X130.805 Y120.781 I-1.987 J154.468 E.19859
G1 X131.183 Y121.695 E.15791
G1 X132.219 Y124.599 E.49229
G1 X132.515 Y126.248 E.26764
G1 X132.619 Y128 E.2802
G1 X132.515 Y129.752 E.2802
G1 X132.219 Y131.399 E.26715
G2 X131.1 Y134.484 I394.077 J144.69 E.52407
G1 X130.759 Y135.2 E.12663
G3 X129.562 Y135.241 I-1.164 J-16.614 E.19126
G1 X124.747 Y135.241 E.76883
G2 X122.767 Y135.746 I.1 J4.521 E.32926
G3 X118.238 Y118.821 I-4.953 J-7.743 E5.51402
G3 X122.762 Y120.252 I-.475 J9.371 E.76601
G2 X123.145 Y120.429 I2.084 J-4.01 E.06736
G1 X123.489 Y120.55 E.05821
M204 S10000
G1 X123.821 Y119.927 F42000
G1 F3215.099
M204 S6000
G1 X123.865 Y119.934 E.00723
G2 X124.755 Y120.06 I.969 J-3.644 E.14387
G1 X129.568 Y120.06 E.76841
G3 X131.285 Y120.109 I.233 J21.753 E.27442
G1 X131.834 Y121.43 E.22836
G1 X131.921 Y121.716 E.0477
G1 X132.897 Y124.417 E.45854
G1 X133.212 Y126.166 E.28373
G1 X133.32 Y128 E.29347
G1 X133.212 Y129.835 E.29347
G1 X132.898 Y131.581 E.28335
G2 X131.747 Y134.754 I402.556 J147.805 E.5388
G1 X131.205 Y135.89 E.20095
G1 X131.036 Y135.886 E.02711
G3 X129.568 Y135.94 I-1.486 J-20.376 E.23457
G1 X124.755 Y135.94 E.76843
G2 X123.1 Y136.362 I.079 J3.772 E.27516
G3 X118.271 Y118.122 I-5.287 J-8.36 E5.9258
G3 X123.097 Y119.637 I-.507 J10.056 E.81641
G2 X123.411 Y119.782 I1.737 J-3.346 E.05521
G1 X123.708 Y119.887 E.05024
M204 S250
G1 X124.222 Y119.297 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.499 Y119.343 E.04488
G2 X124.764 Y119.36 I.323 J-3.004 E.04241
G1 X129.574 Y119.36 E.768
G3 X133.786 Y119.707 I.215 J23.172 E.67587
G3 X135.099 Y120.085 I-1.65 J8.189 E.21831
G3 X135.623 Y120.379 I-.619 J1.719 E.09645
G2 X135.974 Y121.061 I3.334 J-1.285 E.1227
G1 X136.584 Y123.058 E.33335
G1 X136.722 Y123.44 E.06494
G1 X137.128 Y125.699 E.36647
G1 X137.265 Y128 E.36808
G1 X137.128 Y130.301 E.36808
G1 X136.722 Y132.561 E.36652
G1 X135.646 Y135.552 E.50763
G3 X135.546 Y135.662 I-.127 J-.014 E.02536
G3 X134.485 Y136.123 I-1.749 J-2.579 E.18584
G3 X133.72 Y136.295 I-3.196 J-12.392 E.12512
G3 X131.047 Y136.586 I-2.89 J-14.107 E.42997
G3 X129.574 Y136.64 I-1.484 J-20.455 E.23548
G1 X124.764 Y136.64 E.76804
G2 X123.433 Y136.978 I.058 J3.022 E.2211
G3 X118.305 Y117.422 I-5.622 J-8.976 E6.3377
G3 X123.432 Y119.022 I-.539 J10.743 E.86683
G2 X124.041 Y119.258 I1.389 J-2.683 E.10445
G1 X124.104 Y119.272 E.01031
; WIPE_START
M204 S6000
G1 X124.499 Y119.343 E-.15237
G1 X124.764 Y119.36 E-.1009
G1 X126.097 Y119.36 E-.50673
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


G1 X129.55 Y134.541 F42000
G1 Z23.36
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X130.31 Y134.515 E.12141
G1 X130.61 Y133.785 E.12603
G1 X131.541 Y131.216 E.43627
G1 X131.819 Y129.669 E.25096
G1 X131.913 Y128.095 E.25179
G2 X131.819 Y126.331 I-24.797 J.429 E.28208
G1 X131.54 Y124.779 E.25176
G1 X130.53 Y121.946 E.48032
G1 X130.334 Y121.473 E.08176
G2 X126.552 Y121.46 I-2.28 J111.985 E.60396
G1 X127.501 Y123.007 E.28977
G3 X128.035 Y124.214 I-54.456 J24.814 E.21077
G1 X128.401 Y125.41 E.19971
G3 X128.638 Y126.722 I-88.974 J16.744 E.21296
G1 X128.713 Y127.971 E.19974
G1 X128.64 Y129.261 E.20633
G1 X128.415 Y130.533 E.20629
G1 X128.041 Y131.77 E.20629
G3 X127.513 Y132.969 I-54.242 J-23.158 E.2093
G1 X126.553 Y134.541 E.29402
G1 X129.43 Y134.541 E.45941
M204 S10000
G1 X129.538 Y133.841 F42000
G1 F3215.112
M204 S6000
G1 X129.848 Y133.83 E.04954
G1 X130.863 Y131.034 E.47506
G1 X131.123 Y129.586 E.2348
G1 X131.214 Y128.054 E.24516
G2 X131.123 Y126.414 I-30.182 J.852 E.2622
G1 X130.862 Y124.96 E.2359
G1 X129.876 Y122.196 E.46854
G1 X129.829 Y122.164 E.00908
G2 X127.802 Y122.16 I-1.306 J125.432 E.32364
G1 X128.097 Y122.641 E.09015
G3 X128.704 Y124.009 I-24.824 J11.826 E.23898
G1 X129.07 Y125.205 E.19971
G1 X129.322 Y126.557 E.21971
G1 X129.412 Y127.929 E.21953
G1 X129.324 Y129.425 E.23923
G1 X129.075 Y130.777 E.21955
G1 X128.711 Y131.974 E.19968
G3 X128.175 Y133.209 I-58.983 J-24.805 E.21503
G1 X127.801 Y133.841 E.11726
G1 X129.418 Y133.841 E.2583
M204 S10000
G1 X129.244 Y123.038 F42000
; LINE_WIDTH: 1.151
G1 F2182.719
M204 S6000
G3 X129.523 Y123.758 I-11.964 J5.063 E.18167
; LINE_WIDTH: 1.1483
G1 F2188.461
G1 X129.72 Y124.352 E.14674
; LINE_WIDTH: 1.17666
G1 F2129.714
G1 X129.917 Y124.945 E.15078
; LINE_WIDTH: 1.21771
G1 F2050.052
G1 X129.99 Y125.192 E.06444
G1 X130.207 Y126.398 E.30691
G1 X130.235 Y126.626 E.05745
G1 X130.31 Y128.105 E.37089
G1 X130.21 Y129.583 E.371
G1 X129.992 Y130.799 E.30926
G1 X129.921 Y131.035 E.06165
; LINE_WIDTH: 1.17353
G1 F2136.042
G1 X129.723 Y131.628 E.15033
; LINE_WIDTH: 1.14255
G1 F2200.757
G3 X129.277 Y132.857 I-12.276 J-3.763 E.30514
; WIPE_START
G1 X129.526 Y132.222 E-.39655
G1 X129.723 Y131.628 E-.36345
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.19 Y133.213 Z23.76 F42000
G1 Z23.36
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.820367
G1 F3213.413
M204 S2000
G1 X133.71 Y135.693 E.56018
G3 X132.525 Y135.888 I-2.284 J-10.152 E.19212
G1 X136.176 Y132.237 E.82495
G1 X136.393 Y131.03 E.19595
G1 X132.166 Y135.256 E.95491
G1 X132.297 Y134.983 E.04843
G3 X132.776 Y133.656 I167.012 J59.602 E.2253
G1 X136.558 Y129.875 E.85437
G1 X136.62 Y128.822 E.16847
G1 X133.342 Y132.1 E.74066
G1 X133.474 Y131.737 E.06182
G1 X133.64 Y130.812 E.15015
G1 X136.657 Y127.795 E.6815
G1 X136.601 Y126.861 E.1496
G1 X133.819 Y129.643 E.62865
M73 P89 R2
G1 X133.881 Y128.59 E.16847
G1 X136.546 Y125.926 E.602
G1 X136.536 Y125.77 E.02501
G1 X136.411 Y125.071 E.11346
G1 X133.892 Y127.589 E.56911
G1 X133.836 Y126.655 E.1496
G1 X136.26 Y124.231 E.54756
G1 X136.146 Y123.595 E.10327
G1 X136.082 Y123.419 E.02991
G1 X133.743 Y125.758 E.52854
G1 X133.592 Y124.919 E.13624
G1 X135.843 Y122.668 E.50861
G1 X135.611 Y121.909 E.12671
G1 X133.417 Y124.104 E.49585
G1 X133.154 Y123.376 E.12356
G1 X135.357 Y121.174 E.4977
G1 X135.128 Y120.761 E.07539
G1 X134.893 Y120.647 E.04169
G1 X132.891 Y122.649 E.45241
G1 X132.628 Y121.922 E.12356
G1 X134.148 Y120.402 E.34332
G2 X133.329 Y120.23 I-4.117 J17.593 E.13362
G1 X132.377 Y121.183 E.21514
G1 X132.084 Y120.485 E.12084
G1 X132.745 Y119.824 E.14939
; WIPE_START
M204 S6000
G1 X132.084 Y120.485 E-.35534
G1 X132.377 Y121.183 E-.28742
G1 X132.595 Y120.964 E-.11724
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.239 Y125.19 Z23.76 F42000
G1 X112.21 Y134.518 Z23.76
G1 Z23.36
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.424 Y132.38 I5.9 J-6.746 E.44666
G1 X122.192 Y120.612 E2.65742
G2 X119.605 Y119.605 I-4.881 J8.709 E.44481
G1 X128.014 Y128 E1.89742
G1 X119.605 Y136.395 E1.8972
G2 X122.194 Y135.39 I-1.88 J-8.677 E.44518
G1 X110.425 Y123.621 E2.6576
G3 X112.213 Y121.486 I7.479 J4.449 E.44662
; CHANGE_LAYER
; Z_HEIGHT: 23.92
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.448 Y122.219 E-.4029
G1 X110.911 Y122.872 E-.32113
G1 X110.86 Y122.952 E-.03598
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 43/51
; update layer progress
M73 L43
M991 S0 P42 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z23.92 I.301 J1.677 P1  F42000
G1 X123.758 Y120.633 Z23.92
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X123.839 Y120.654 E.01335
G2 X124.747 Y120.76 I.951 J-4.191 E.14628
G3 X128.422 Y120.78 I1.226 J111.85 E.58682
G1 X129.345 Y122.277 E.28083
G1 X129.556 Y122.756 E.08352
G1 X129.794 Y123.537 E.13034
G1 X130.342 Y125.052 E.25734
G1 X130.598 Y126.477 E.23111
G1 X130.688 Y128 E.24368
G1 X130.598 Y129.524 E.24368
G1 X130.342 Y130.945 E.23059
G1 X129.749 Y132.577 E.27723
G1 X129.524 Y133.314 E.12311
G1 X129.333 Y133.748 E.07563
G1 X128.427 Y135.214 E.27526
G3 X124.747 Y135.241 I-2.422 J-81.782 E.58771
G2 X122.766 Y135.747 I.099 J4.517 E.32928
G3 X118.247 Y118.821 I-4.953 J-7.744 E5.51548
G3 X122.762 Y120.252 I-.481 J9.36 E.76453
G2 X123.305 Y120.495 I2.028 J-3.789 E.09509
G1 X123.643 Y120.598 E.05649
M204 S10000
G1 X123.955 Y119.963 F42000
G1 F3215.099
M204 S6000
G1 X123.994 Y119.971 E.00643
G2 X124.756 Y120.06 I.795 J-3.504 E.12265
G3 X128.824 Y120.098 I1.274 J80.521 E.64975
G1 X129.966 Y121.951 E.34747
G1 X130.213 Y122.512 E.09784
G1 X130.458 Y123.315 E.13414
M73 P89 R1
G1 X131.02 Y124.87 E.264
G1 X131.294 Y126.394 E.2472
G1 X131.389 Y128 E.25694
G1 X131.294 Y129.607 E.25694
G1 X131.021 Y131.128 E.2468
G1 X130.413 Y132.799 E.28386
G1 X130.181 Y133.558 E.12683
G1 X129.954 Y134.074 E.09
G1 X128.83 Y135.895 E.34165
G3 X127.205 Y135.94 I-1.467 J-23.195 E.25964
G1 X124.756 Y135.94 E.3911
G2 X123.1 Y136.362 I.078 J3.768 E.2752
G3 X118.281 Y118.122 I-5.287 J-8.36 E5.92734
G3 X123.097 Y119.637 I-.514 J10.046 E.81487
G2 X123.548 Y119.839 I1.692 J-3.17 E.079
G1 X123.84 Y119.928 E.04868
M204 S250
G1 X124.539 Y119.35 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.764 Y119.36 E.03593
G3 X129.048 Y119.41 I1.303 J72.237 E.68418
G1 X129.663 Y119.472 E.0988
G3 X130.838 Y119.575 I-.054 J7.425 E.18852
G3 X132.617 Y119.959 I-1.421 J10.888 E.29092
G1 X133.196 Y120.186 E.09924
G1 X133.523 Y120.388 E.06135
G3 X133.695 Y120.642 I-.614 J.602 E.04917
G1 X133.829 Y121.08 E.07327
G1 X134.845 Y123.894 E.47764
G1 X135.211 Y125.927 E.32994
G1 X135.334 Y128 E.33155
G1 X135.211 Y130.073 E.33155
G1 X134.845 Y132.106 E.32987
G2 X133.617 Y135.492 I430.23 J157.96 E.575
G3 X133.437 Y135.663 I-.656 J-.508 E.03993
G1 X133.186 Y135.818 E.04707
G3 X131.935 Y136.218 I-2.279 J-4.978 E.21017
G3 X130.038 Y136.515 I-3.153 J-13.906 E.30696
G1 X129.719 Y136.55 E.05109
G3 X127.211 Y136.64 I-2.542 J-35.776 E.40091
G1 X124.764 Y136.64 E.39071
G2 X123.433 Y136.978 I.057 J3.019 E.22113
G3 X118.315 Y117.423 I-5.621 J-8.976 E6.3393
G3 X123.432 Y119.022 I-.546 J10.734 E.86525
G2 X124.42 Y119.337 I1.356 J-2.551 E.1664
; WIPE_START
M204 S6000
G1 X124.764 Y119.36 E-.13105
G1 X126.419 Y119.36 E-.62895
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


G1 X131.222 Y119.927 F42000
G1 Z23.92
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.834987
G1 F3147.689
M204 S2000
G1 X133.66 Y122.365 E.56232
G1 X134.232 Y123.947 E.27445
G1 X130.404 Y120.119 E.88303
G2 X129.508 Y120.075 I-.672 J4.556 E.14642
G1 X129.765 Y120.491 E.07971
G1 X134.476 Y125.202 E1.08664
G1 X134.619 Y125.998 E.13189
G1 X134.642 Y126.379 E.06218
G1 X130.861 Y122.598 E.87189
G2 X131.387 Y124.135 I15.539 J-4.457 E.26494
G1 X134.705 Y127.453 E.76539
G3 X134.71 Y128.469 I-4.26 J.527 E.16602
G1 X131.737 Y125.496 E.68574
G1 X131.886 Y126.323 E.13714
G1 X131.907 Y126.676 E.05767
G1 X134.653 Y129.423 E.63353
G3 X134.559 Y130.339 I-3.892 J.06 E.15055
G1 X131.97 Y127.751 E.59694
G1 X131.985 Y128 E.04072
G1 X131.942 Y128.733 E.11975
G1 X134.405 Y131.196 E.56804
G1 X134.269 Y131.951 E.12511
G1 X134.237 Y132.039 E.0153
G1 X131.884 Y129.686 E.54265
G1 X131.73 Y130.543 E.14199
G1 X133.967 Y132.78 E.516
G1 X133.698 Y133.522 E.12865
G1 X131.56 Y131.384 E.49299
G1 X131.291 Y132.126 E.12865
G1 X133.428 Y134.263 E.49299
G2 X133.16 Y135.006 I94.133 J34.419 E.12878
G1 X131.021 Y132.867 E.4933
G2 X130.779 Y133.636 I7.209 J2.689 E.13155
G1 X132.564 Y135.421 E.41167
G1 X132.383 Y135.491 E.03171
G1 X131.777 Y135.644 E.10195
G1 X130.482 Y134.35 E.29856
G1 X130.097 Y134.975 E.11981
G1 X130.927 Y135.806 E.1915
G1 X130.028 Y135.917 E.14777
G1 X129.482 Y135.371 E.12589
; WIPE_START
M204 S6000
G1 X130.028 Y135.917 E-.29332
G1 X130.927 Y135.806 E-.3443
G1 X130.699 Y135.578 E-.12238
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.191 Y134.541 Z24.32 F42000
G1 Z23.92
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X128.032 Y134.523 E.13429
G1 X128.712 Y133.421 E.20675
G2 X129.082 Y132.364 I-5.363 J-2.472 E.17916
G3 X129.664 Y130.762 I483.961 J174.9 E.27207
G1 X129.902 Y129.441 E.21436
G1 X129.982 Y128.095 E.21527
G2 X129.902 Y126.56 I-21.611 J.354 E.24555
G1 X129.664 Y125.234 E.21499
G1 X129.133 Y123.766 E.24928
G2 X128.724 Y122.603 I-6.207 J1.531 E.19714
G1 X128.027 Y121.473 E.21193
G2 X124.552 Y121.455 I-2.341 J116.946 E.55494
G1 X123.803 Y121.358 E.1206
G1 X125.102 Y122.778 E.30728
M73 P90 R1
G1 X125.784 Y123.889 E.20813
G1 X126.225 Y124.886 E.17409
G1 X126.524 Y125.863 E.16316
G1 X126.716 Y126.909 E.16984
G1 X126.782 Y127.971 E.16983
G1 X126.723 Y129.033 E.16979
G1 X126.538 Y130.08 E.16977
G1 X126.231 Y131.097 E.16974
G3 X125.772 Y132.127 I-16.231 J-6.616 E.18001
G1 X125.14 Y133.172 E.195
G3 X123.809 Y134.637 I-109.721 J-98.316 E.3161
G1 X124.707 Y134.542 E.14411
G3 X127.071 Y134.541 I1.668 J791.756 E.37752
M204 S10000
G1 X127.184 Y133.841 F42000
G1 F3215.112
M204 S6000
G1 X127.636 Y133.831 E.07232
G1 X128.091 Y133.095 E.13824
G3 X128.986 Y130.579 I84.791 J28.748 E.4263
G1 X129.206 Y129.358 E.19816
G1 X129.283 Y128.054 E.20863
G2 X129.206 Y126.643 I-26.018 J.719 E.22568
G1 X128.985 Y125.416 E.1989
G1 X128.475 Y124.004 E.23982
G1 X128.257 Y123.295 E.11838
G1 X128.03 Y122.812 E.08525
G1 X127.633 Y122.167 E.121
G2 X125.482 Y122.157 I-1.453 J80.921 E.34342
G1 X125.741 Y122.47 E.06488
G1 X126.382 Y123.526 E.19726
G1 X126.846 Y124.554 E.18004
G1 X127.193 Y125.658 E.18482
G1 X127.404 Y126.785 E.18306
G1 X127.481 Y127.929 E.18316
G1 X127.421 Y129.074 E.183
G1 X127.227 Y130.203 E.18288
G1 X126.9 Y131.301 E.18296
G3 X126.371 Y132.489 I-13.237 J-5.187 E.20774
G1 X125.739 Y133.534 E.195
G1 X125.486 Y133.841 E.06354
G1 X127.064 Y133.841 E.25194
M204 S10000
G1 X127.132 Y123.048 F42000
; LINE_WIDTH: 1.21248
G1 F2059.874
M204 S6000
G1 X127.393 Y123.559 E.14298
; LINE_WIDTH: 1.20597
G1 F2072.215
G1 X127.514 Y123.882 E.08545
; LINE_WIDTH: 1.15517
G1 F2173.926
G3 X127.715 Y124.429 I-33.467 J12.638 E.13765
; LINE_WIDTH: 1.15115
G1 F2182.411
G1 X127.877 Y124.914 E.12022
; LINE_WIDTH: 1.17633
G1 F2130.379
G1 X128.039 Y125.399 E.12316
; LINE_WIDTH: 1.21453
G1 F2056.013
G1 X128.289 Y126.625 E.31245
G1 X128.317 Y126.854 E.0577
G3 X128.379 Y128.105 I-10.931 J1.167 E.31285
G3 X128.292 Y129.355 I-10.979 J-.133 E.31296
G1 X128.115 Y130.345 E.25109
G1 X128.044 Y130.581 E.06165
; LINE_WIDTH: 1.17594
G1 F2131.156
G1 X127.882 Y131.066 E.12309
; LINE_WIDTH: 1.14867
G1 F2187.663
G1 X127.721 Y131.551 E.11992
; LINE_WIDTH: 1.15749
G1 F2169.072
G1 X127.541 Y132.031 E.12134
; LINE_WIDTH: 1.2071
G1 F2070.055
G3 X127.189 Y132.844 I-3.444 J-1.011 E.22025
M204 S10000
G1 X112.209 Y134.52 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G3 X110.422 Y132.382 I6.05 J-6.876 E.4467
G1 X122.192 Y120.612 E2.65788
G2 X119.601 Y119.601 I-4.547 J7.83 E.4458
G1 X125.761 Y125.761 E1.39103
G3 X125.762 Y130.238 I-7.561 J2.239 E.72484
G1 X119.606 Y136.395 E1.39013
G2 X122.194 Y135.39 I-1.881 J-8.681 E.44514
G1 X110.417 Y123.613 E2.65925
G3 X112.215 Y121.484 I8.004 J4.935 E.44663
; CHANGE_LAYER
; Z_HEIGHT: 24.48
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3215.099
G1 X111.161 Y122.551 E-.57001
G1 X110.874 Y122.961 E-.18999
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 44/51
; update layer progress
M73 L44
M991 S0 P43 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z24.48 I.285 J1.68 P1  F42000
G1 X124.137 Y120.712 Z24.48
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3215.099
M204 S6000
G1 X124.194 Y120.721 E.00922
G2 X124.557 Y120.756 I.593 J-4.234 E.05822
G1 X126.186 Y120.782 E.2601
G3 X127.556 Y123.016 I-137.903 J86.115 E.41841
G1 X128.072 Y124.187 E.20442
G1 X128.451 Y125.428 E.20716
G1 X128.68 Y126.705 E.20716
G1 X128.757 Y128 E.20715
G1 X128.68 Y129.295 E.20715
G1 X128.451 Y130.572 E.20718
G1 X128.072 Y131.813 E.20712
G1 X127.559 Y132.978 E.2033
G1 X126.192 Y135.213 E.41834
G1 X124.557 Y135.245 E.26106
G2 X122.766 Y135.747 I.23 J4.267 E.29946
G3 X118.256 Y118.821 I-4.952 J-7.744 E5.51682
G3 X122.761 Y120.251 I-.493 J9.367 E.76286
G2 X123.838 Y120.655 I2.027 J-3.764 E.18434
G1 X124.019 Y120.69 E.02945
M204 S10000
G1 X124.261 Y120.023 F42000
G1 F3215.099
M204 S6000
G1 X124.289 Y120.027 E.00455
G2 X124.595 Y120.057 I.494 J-3.526 E.04909
G3 X126.592 Y120.108 I.34 J25.764 E.31906
G3 X128.178 Y122.692 I-159.696 J99.761 E.48419
G1 X128.729 Y123.943 E.2183
G1 X129.132 Y125.264 E.22042
G1 X129.377 Y126.622 E.22042
G1 X129.458 Y128 E.22041
G1 X129.377 Y129.378 E.22042
G1 X129.132 Y130.737 E.22043
G1 X128.729 Y132.057 E.22039
G1 X128.18 Y133.303 E.21743
G1 X126.596 Y135.892 E.48465
G3 X124.595 Y135.944 I-1.705 J-27.352 E.31974
G2 X123.099 Y136.362 I.188 J3.554 E.25003
G3 X118.29 Y118.122 I-5.287 J-8.36 E5.92879
G3 X123.096 Y119.636 I-.526 J10.053 E.81321
G2 X123.993 Y119.973 I1.687 J-3.135 E.15347
G1 X124.143 Y120.001 E.02435
M204 S250
G1 X124.781 Y119.36 F42000
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X126.132 Y119.388 E.21578
G3 X128.507 Y119.569 I-1.448 J34.534 E.38051
G3 X130.722 Y120.076 I-1.177 J10.24 E.36358
G3 X131.328 Y120.382 I-.536 J1.816 E.10896
G3 X131.749 Y121.014 I-2.591 J2.181 E.12157
G1 X132.1 Y121.811 E.13897
G1 X132.366 Y122.68 E.1451
G1 X132.968 Y124.347 E.2831
G1 X133.293 Y126.156 E.2934
G1 X133.403 Y128 E.29502
G1 X133.293 Y129.845 E.29502
G1 X132.968 Y131.653 E.29334
G1 X132.32 Y133.436 E.3029
G1 X132.068 Y134.259 E.13748
G1 X131.737 Y135.011 E.13127
G1 X131.48 Y135.427 E.07802
G3 X131.179 Y135.71 I-.682 J-.424 E.0668
G3 X130.621 Y135.958 I-1.079 J-1.677 E.09791
G3 X129.045 Y136.344 I-2.786 J-7.978 E.2594
G3 X126.109 Y136.619 I-3.633 J-22.95 E.47118
G1 X124.633 Y136.643 E.2357
G2 X123.433 Y136.978 I.145 J2.842 E.2006
G3 X118.324 Y117.423 I-5.621 J-8.976 E6.34085
G3 X123.432 Y119.022 I-.559 J10.741 E.86357
G2 X124.633 Y119.357 I1.347 J-2.506 E.20085
G1 X124.661 Y119.358 E.00436
; WIPE_START
M204 S6000
G1 X126.132 Y119.388 E-.55913
G1 X126.66 Y119.414 E-.20087
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


G1 X122.74 Y131.982 F42000
G1 Z24.48
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G3 X120.719 Y133.915 I-11.314 J-9.803 E.44718
G1 X110.935 Y124.131 E2.2093
G2 X110.937 Y131.867 I6.881 J3.867 E1.29088
G1 X120.723 Y122.081 E2.20975
G1 X119.718 Y121.178 E.21582
G1 X119.627 Y120.686 E.07989
G1 X119.789 Y120.368 E.05693
G2 X119.213 Y120.237 I-.965 J2.917 E.09442
M204 S10000
G1 X120.372 Y136.147 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.800177
G1 F3308.823
M204 S6000
G3 X117.952 Y136.531 I-2.622 J-8.692 E.38131
G1 X116.727 Y136.472 E.19027
G3 X118.224 Y119.478 I1.086 J-8.467 E4.0557
G1 X119.434 Y119.616 E.18888
G1 X120.334 Y119.849 E.14435
M204 S10000
G1 X123.416 Y134.745 F42000
; LINE_WIDTH: 0.81942
G1 F3217.764
M204 S6000
G1 X123.713 Y134.655 E.04953
G1 X124.49 Y134.548 E.12511
G1 X125.795 Y134.521 E.20824
G1 X126.937 Y132.653 E.34931
G1 X127.415 Y131.569 E.18901
G1 X127.769 Y130.408 E.19373
G1 X127.984 Y129.212 E.19372
G1 X128.051 Y128.095 E.17859
G1 X127.996 Y126.987 E.17691
G1 X127.805 Y125.788 E.19372
G1 X127.473 Y124.622 E.19341
G1 X127.013 Y123.518 E.19084
G2 X125.79 Y121.476 I-52.297 J29.904 E.37981
G1 X124.532 Y121.455 E.20072
G1 X124.07 Y121.411 E.07419
G1 X123.314 Y121.239 E.12356
G3 X122.432 Y120.869 I3.062 J-8.527 E.1528
G1 X121.375 Y120.297 E.19169
G1 X120.448 Y119.888 E.16165
G1 X120.608 Y120.302 E.07079
G1 X120.358 Y120.792 E.08782
G2 X122.528 Y122.764 I39.74 J-41.556 E.46787
G3 X123.622 Y124.026 I-9.645 J9.469 E.26659
G1 X124.067 Y124.773 E.13867
G1 X124.4 Y125.52 E.1305
G1 X124.647 Y126.316 E.13307
G1 X124.798 Y127.138 E.13325
G1 X124.851 Y127.97 E.13313
G1 X124.805 Y128.804 E.13314
G1 X124.661 Y129.626 E.13317
G1 X124.421 Y130.425 E.13312
M73 P91 R1
G1 X124.096 Y131.171 E.12974
G1 X123.625 Y131.97 E.14814
G3 X122.815 Y132.93 I-5.256 J-3.615 E.20064
G1 X122.117 Y133.603 E.15464
G1 X120.325 Y135.207 E.3837
G1 X120.572 Y135.705 E.08875
G1 X120.372 Y136.147 E.07738
G2 X122.818 Y134.946 I-12.557 J-28.659 E.43491
G1 X123.302 Y134.783 E.0815
M204 S10000
G1 X124.28 Y133.871 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G3 X125.398 Y133.828 I1.169 J16.117 E.17864
G1 X126.316 Y132.328 E.28087
G1 X126.758 Y131.325 E.17504
G1 X127.088 Y130.243 E.18063
G1 X127.288 Y129.13 E.18061
G1 X127.352 Y128.054 E.17211
G1 X127.298 Y127.029 E.16384
G1 X127.116 Y125.912 E.18065
G1 X126.804 Y124.827 E.18034
G1 X126.372 Y123.801 E.17777
G2 X125.395 Y122.169 I-51.302 J29.629 E.30367
G3 X123.16 Y121.922 I-.302 J-7.501 E.36043
G1 X122.21 Y121.537 E.16367
G1 X122.996 Y122.244 E.16885
G3 X124.216 Y123.656 I-8.643 J8.702 E.29829
G1 X124.668 Y124.415 E.141
G1 X125.04 Y125.237 E.14405
G1 X125.316 Y126.111 E.14642
G1 X125.487 Y127.013 E.14656
G1 X125.55 Y127.928 E.14648
G1 X125.504 Y128.844 E.14646
G1 X125.35 Y129.749 E.14651
G1 X125.09 Y130.628 E.14645
G1 X124.737 Y131.452 E.14306
G1 X124.227 Y132.327 E.16183
G3 X123.328 Y133.405 I-5.754 J-3.881 E.22442
G3 X122.157 Y134.506 I-15.089 J-14.881 E.2567
G1 X122.659 Y134.255 E.08961
G1 X123.436 Y134.003 E.13043
G1 X124.162 Y133.889 E.11723
M204 S10000
G1 X124.889 Y123.055 F42000
; LINE_WIDTH: 1.21657
G1 F2052.182
M204 S6000
G1 X125.439 Y123.956 E.26389
G1 X125.862 Y124.873 E.2527
G1 X126.175 Y125.847 E.25604
G1 X126.371 Y126.853 E.2562
G1 X126.447 Y127.874 E.25615
G1 X126.401 Y128.896 E.25605
G1 X126.235 Y129.907 E.25617
G1 X125.95 Y130.89 E.25604
G1 X125.56 Y131.813 E.25074
G3 X124.955 Y132.842 I-14.084 J-7.59 E.29874
; WIPE_START
G1 X125.56 Y131.813 E-.4537
G1 X125.874 Y131.071 E-.30631
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.711 Y134.376 Z24.88 F42000
G1 Z24.48
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.834377
G1 F3150.378
M204 S2000
G1 X130.907 Y135.18 E.1853
G3 X130.424 Y135.397 I-1.376 J-2.418 E.08648
G3 X129.408 Y135.669 I-1.865 J-4.928 E.17165
G1 X131.723 Y133.354 E.53349
G1 X132.29 Y131.777 E.27315
G1 X128.202 Y135.865 E.94218
G1 X127.249 Y135.966 E.15619
G1 X127.497 Y135.56 E.07761
G1 X132.574 Y130.483 E1.17002
G1 X132.702 Y129.774 E.11735
G1 X132.729 Y129.319 E.07439
G1 X128.898 Y133.149 E.88268
G1 X129.288 Y132.264 E.15745
G1 X129.514 Y131.523 E.12639
G1 X132.792 Y128.245 E.75541
G1 X132.807 Y128 E.03991
G1 X132.763 Y127.264 E.1202
G1 X129.835 Y130.192 E.67488
G1 X129.968 Y129.449 E.12312
G1 X129.993 Y129.023 E.06943
G1 X132.707 Y126.31 E.62522
G1 X132.561 Y125.446 E.14289
G1 X130.052 Y127.955 E.57836
G1 X129.995 Y127.002 E.15564
G1 X132.407 Y124.59 E.55594
G1 X132.392 Y124.502 E.01447
G1 X132.151 Y123.836 E.11543
G1 X129.887 Y126.1 E.52173
G1 X129.733 Y125.244 E.14175
G1 X131.883 Y123.094 E.49541
G3 X131.637 Y122.33 I7.47 J-2.826 E.13086
G1 X129.508 Y124.458 E.49052
G1 X129.267 Y123.689 E.13132
G1 X131.357 Y121.6 E.48164
G2 X131.006 Y120.941 I-2.555 J.941 E.12202
G1 X128.958 Y122.988 E.47178
G1 X128.707 Y122.417 E.10168
G1 X128.636 Y122.3 E.02224
G1 X130.362 Y120.575 E.39773
G2 X129.569 Y120.357 I-20.205 J72.231 E.13397
G1 X128.255 Y121.672 E.30285
G1 X127.87 Y121.047 E.11962
G1 X128.712 Y120.205 E.19395
G2 X127.813 Y120.094 I-1.445 J7.979 E.14764
G1 X127.256 Y120.651 E.12834
; CHANGE_LAYER
; Z_HEIGHT: 25.04
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3150.378
M204 S6000
G1 X127.813 Y120.094 E-.29929
G1 X128.712 Y120.205 E-.34412
G1 X128.495 Y120.422 E-.1166
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 45/51
; update layer progress
M73 L45
M991 S0 P44 ;notify layer change
M106 S196.35
; OBJECT_ID: 15
M204 S10000
G17
G3 Z25.04 I-.086 J-1.702 P1  F42000
G1 X123.246 Y120.686 Z25.04
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X125.169 Y122.789 E.455
G2 X125.838 Y123.898 I51.407 J-30.256 E.20671
G1 X126.262 Y124.86 E.1679
G1 X126.574 Y125.882 E.17061
G1 X126.763 Y126.934 E.17064
G1 X126.826 Y128 E.17061
G1 X126.763 Y129.067 E.17061
G1 X126.574 Y130.119 E.17065
G1 X126.262 Y131.141 E.1706
G1 X125.839 Y132.1 E.16739
G2 X125.149 Y133.24 I43.881 J27.373 E.2128
G1 X122.989 Y135.595 E.51023
G3 X121.692 Y136.291 I-54.321 J-99.735 E.23508
G3 X117.435 Y137.132 I-3.797 J-8.025 E.69995
G3 X114.762 Y136.616 I.141 J-7.92 E.43682
G3 X112.816 Y135.657 I2.227 J-6.968 E.34772
G3 X111.2 Y134.338 I4.071 J-6.641 E.33406
G3 X109.521 Y131.852 I6.114 J-5.94 E.4816
G3 X108.679 Y128.703 I7.436 J-3.675 E.52393
G3 X118.196 Y118.853 I9.131 J-.7 E2.47054
G3 X122.749 Y120.284 I-.449 J9.391 E.77055
G1 X122.989 Y120.405 E.04285
G1 X123.165 Y120.598 E.04172
; WIPE_START
G1 X124.515 Y122.074 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.019 Y120.043 Z25.44 F42000
G1 Z25.04
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X123.857 Y120.317 E.05086
G1 X125.699 Y122.332 E.4358
G3 X125.863 Y122.588 I-.995 J.817 E.04874
G1 X126.46 Y123.574 E.18402
G1 X126.919 Y124.616 E.18177
G1 X127.255 Y125.717 E.18387
G1 X127.459 Y126.851 E.1839
G1 X127.527 Y128 E.18388
G1 X127.459 Y129.15 E.18388
G1 X127.255 Y130.283 E.18391
G1 X126.919 Y131.385 E.18386
G1 X126.461 Y132.424 E.18139
G3 X125.685 Y133.69 I-16.74 J-9.393 E.23718
G1 X123.888 Y135.65 E.42451
G1 X124.057 Y135.943 E.05397
G2 X122.733 Y136.541 I1.272 J4.579 E.23277
G3 X117.439 Y137.833 I-4.837 J-8.326 E.88226
G3 X114.54 Y137.281 I.113 J-8.481 E.47361
G3 X112.463 Y136.262 I2.461 J-7.645 E.37071
G3 X110.469 Y134.579 I4.217 J-7.018 E.41837
G3 X108.89 Y132.159 I6.922 J-6.239 E.46334
G3 X107.981 Y128.757 I8.106 J-3.99 E.56582
G3 X118.224 Y118.154 I9.829 J-.755 E2.65934
G3 X123.088 Y119.671 I-.478 J10.088 E.82235
G2 X123.904 Y120.008 I2.371 J-4.578 E.14126
; WIPE_START
G1 X123.857 Y120.317 E-.11886
G1 X124.996 Y121.563 E-.64115
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.743 Y119.447 Z25.44 F42000
G1 Z25.04
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.821 Y119.456 E.01245
G3 X127.243 Y119.758 I-1.323 J20.487 E.38993
G2 X128.007 Y119.934 I3.44 J-13.121 E.12524
G2 X128.621 Y120.14 I3.456 J-9.295 E.10352
G3 X129.071 Y120.372 I-1.09 J2.662 E.08085
G3 X129.218 Y120.537 I-.526 J.617 E.03536
G3 X129.965 Y121.763 I-75.909 J47.094 E.22923
G1 X130.616 Y123.242 E.25812
G1 X131.089 Y124.791 E.2585
G1 X131.376 Y126.384 E.25853
G1 X131.472 Y128 E.25849
G1 X131.376 Y129.616 E.25849
G1 X131.089 Y131.21 E.25853
G1 X130.616 Y132.758 E.25849
G1 X129.965 Y134.237 E.25801
G1 X129.218 Y135.458 E.22851
G1 X129.087 Y135.615 E.03274
G3 X128.714 Y135.804 I-.854 J-1.225 E.06709
G3 X127.19 Y136.249 I-2.745 J-6.578 E.25401
G3 X124.476 Y136.583 I-4.662 J-26.66 E.43678
G2 X123.077 Y137.151 I.575 J3.424 E.24298
G3 X117.443 Y138.534 I-5.183 J-8.944 E.93896
G3 X114.318 Y137.946 I.139 J-9.327 E.51023
G3 X112.109 Y136.868 I2.701 J-8.337 E.39372
G3 X109.948 Y135.047 I4.657 J-7.72 E.45314
G3 X108.26 Y132.466 I7.486 J-6.737 E.49437
G3 X107.283 Y128.812 I8.612 J-4.261 E.60786
G3 X118.253 Y117.454 I10.527 J-.809 E2.84815
G3 X123.426 Y119.057 I-.508 J10.787 E.87414
G2 X124.489 Y119.417 I1.633 J-3.077 E.17991
G1 X124.624 Y119.433 E.02181
; WIPE_START
M204 S6000
G1 X124.821 Y119.456 E-.07522
G1 X126.281 Y119.6 E-.55753
G1 X126.612 Y119.654 E-.12726
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
M106 S255
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


G1 X126.818 Y119.966 F42000
G1 Z25.04
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.831757
G1 F3161.978
M204 S2000
G1 X129.866 Y123.014 E.69981
G1 X130.058 Y123.45 E.0774
G1 X130.393 Y124.547 E.18628
M73 P92 R1
G1 X126.013 Y120.167 E1.00574
G2 X124.899 Y120.059 I-2.521 J20.236 E.18176
G1 X130.672 Y125.833 E1.32568
G3 X130.815 Y126.982 I-4.753 J1.175 E.1885
G1 X126.769 Y122.936 E.92902
G1 X126.989 Y123.299 E.06889
G1 X127.478 Y124.408 E.1968
G1 X127.584 Y124.757 E.05924
G1 X130.873 Y128.046 E.75515
G1 X130.817 Y128.996 E.1545
G1 X127.93 Y126.11 E.66273
G3 X128.08 Y127.265 I-4.777 J1.205 E.18962
G1 X130.719 Y129.905 E.60614
G1 X130.566 Y130.758 E.14071
G1 X128.106 Y128.298 E.56497
G1 X128.046 Y129.245 E.15408
G1 X130.361 Y131.559 E.53139
G1 X130.125 Y132.33 E.13087
G1 X127.893 Y130.098 E.51254
G3 X127.689 Y130.9 I-3.471 J-.456 E.13471
G1 X129.838 Y133.049 E.49349
G1 X129.53 Y133.748 E.12394
G1 X127.446 Y131.664 E.47859
G1 X127.138 Y132.362 E.12394
G1 X129.171 Y134.395 E.46673
G1 X128.789 Y135.019 E.11883
G1 X126.793 Y133.023 E.45833
G1 X126.412 Y133.649 E.11891
G1 X128.155 Y135.392 E.40017
G3 X127.362 Y135.605 I-2.089 J-6.196 E.13345
G1 X125.992 Y134.235 E.31449
G1 X125.511 Y134.76 E.11564
G1 X126.511 Y135.76 E.22951
G3 X125.623 Y135.878 I-2.391 J-14.489 E.14541
G1 X124.807 Y135.062 E.18739
; WIPE_START
M204 S6000
G1 X125.623 Y135.878 E-.4386
G1 X126.461 Y135.766 E-.3214
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.471 Y132.275 Z25.44 F42000
G1 Z25.04
G1 E.8 F1800
; FEATURE: Bridge
; LINE_WIDTH: 0.84471
; LAYER_HEIGHT: 0.8

M204 S6000
G1 X120.213 Y136.132 E1.31167
G3 X118.61 Y136.447 I-2.559 J-8.78 E.37366
G1 X118.527 Y136.453 E.01891
G1 X124.832 Y130.74 E1.94262
G2 X125.255 Y129.15 I-6.762 J-2.648 E.37647
G1 X117.192 Y136.455 E2.48417
G1 X116.469 Y136.379 E.16603
G1 X116.038 Y136.293 E.1003
G1 X125.346 Y127.861 E2.8677
G2 X125.295 Y127.074 I-6.689 J.036 E.18001
G1 X125.237 Y126.752 E.07483
G1 X115.028 Y136.001 E3.14549
G3 X114.179 Y135.671 I1.743 J-5.734 E.20812
G1 X114.104 Y135.631 E.01949
G1 X125 Y125.759 E3.35713
G2 X124.657 Y124.863 I-4.232 J1.104 E.21965
G1 X113.284 Y135.167 E3.50421
G3 X112.536 Y134.637 I2.248 J-3.964 E.20961
G1 X124.22 Y124.051 E3.59997
G2 X123.707 Y123.309 I-3.701 J2.01 E.20646
G1 X111.854 Y134.047 E3.65183
G3 X111.255 Y133.383 I4.577 J-4.737 E.20445
G1 X123.105 Y122.647 E3.65094
G2 X122.457 Y122.027 I-3.93 J3.455 E.20506
G1 X110.723 Y132.657 E3.61527
G3 X110.258 Y131.871 I7.805 J-5.137 E.20865
G1 X121.788 Y121.426 E3.55228
G1 X121.119 Y120.824 E.20536
G1 X109.88 Y131.007 E3.46287
G3 X109.58 Y130.071 I9.046 J-3.416 E.22442
G1 X120.673 Y120.021 E3.41785
G1 X120.551 Y119.978 E.02966
G2 X119.67 Y119.723 I-2.038 J5.389 E.20964
G1 X109.392 Y129.034 E3.16662
G3 X109.327 Y127.886 I6.904 J-.966 E.26297
G1 X118.527 Y119.55 E2.83466
G2 X117.197 Y119.548 I-.677 J7.629 E.30415
G1 X109.453 Y126.564 E2.38601
G1 X109.583 Y125.914 E.15144
G1 X109.845 Y125.071 E.20146
G3 X109.889 Y124.962 I.588 J.174 E.02708
G1 X115.567 Y119.818 E1.74942
G2 X113.123 Y120.938 I2.294 J8.229 E.61643
G2 X112.573 Y121.323 I2.831 J4.633 E.15348
G1 X110.166 Y123.503 E.74146
M106 S196.35
M204 S10000
G1 X122.525 Y120.994 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.88356
; LAYER_HEIGHT: 0.56
G1 F2947.405
M204 S6000
G1 X122.83 Y121.297 E.07483
; LINE_WIDTH: 0.850207
G1 F3082.065
G1 X123.135 Y121.6 E.07156
; LINE_WIDTH: 0.815073
G1 F3237.895
G3 X124.605 Y123.211 I-18.121 J18.004 E.3459
G1 X125.216 Y124.221 E.18708
G1 X125.605 Y125.104 E.15302
G1 X125.892 Y126.047 E.15628
G1 X126.067 Y127.016 E.15623
G1 X126.125 Y128 E.15626
G1 X126.067 Y128.984 E.15626
G1 X125.892 Y129.954 E.15624
G1 X125.605 Y130.896 E.15625
G1 X125.217 Y131.776 E.15241
G1 X124.696 Y132.651 E.1614
G3 X124.248 Y133.221 I-5.409 J-3.786 E.11506
G3 X123.442 Y134.097 I-18.863 J-16.546 E.18874
; LINE_WIDTH: 0.81748
G1 F3226.716
G1 X123.165 Y134.371 E.06201
; LINE_WIDTH: 0.852087
G1 F3074.148
G1 X122.888 Y134.645 E.06509
; LINE_WIDTH: 0.886694
G1 F2935.357
G1 X122.611 Y134.919 E.06817
; CHANGE_LAYER
; Z_HEIGHT: 25.6
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2935.357
G1 X122.888 Y134.645 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 46/51
; update layer progress
M73 L46
M991 S0 P45 ;notify layer change
M106 S198.9
; OBJECT_ID: 15
M204 S10000
G17
G3 Z25.6 I1.702 J-.083 P1  F42000
G1 X122.298 Y122.5 Z25.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X122.575 Y122.749 E.05943
G3 X123.652 Y123.991 I-9.067 J8.951 E.26274
G3 X124.452 Y125.532 I-6.851 J4.533 E.27767
G1 X124.697 Y126.335 E.1341
G1 X124.845 Y127.162 E.1341
G1 X124.895 Y128 E.13408
G1 X124.845 Y128.838 E.13408
G1 X124.697 Y129.665 E.13411
G1 X124.452 Y130.468 E.13408
G1 X124.121 Y131.218 E.13085
G2 X123.645 Y132.019 I30.594 J18.736 E.14883
G3 X122.725 Y133.097 I-6.444 J-4.571 E.22659
G1 X122.578 Y133.248 E.03363
G1 X120.366 Y135.227 E.47385
G1 X120.962 Y136.351 E.20327
G3 X117.976 Y119.076 I-3.149 J-8.352 E5.01714
G3 X120.986 Y119.656 I-.195 J9.106 E.49183
G1 X120.403 Y120.796 E.20445
G1 X122.209 Y122.42 E.38773
; WIPE_START
G1 X122.575 Y122.749 E-.18704
G1 X123.312 Y123.546 E-.4124
G1 X123.568 Y123.882 E-.16056
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.949 Y119.308 Z26 F42000
G1 Z25.6
G1 E.8 F1800
G1 F3215.099
M204 S6000
G1 X121.271 Y120.636 E.238
G1 X123.06 Y122.245 E.38421
G3 X124.234 Y123.6 I-9.641 J9.532 E.28641
G3 X125.109 Y125.288 I-7.582 J5.002 E.30419
G1 X125.378 Y126.171 E.14737
G1 X125.542 Y127.079 E.14736
G1 X125.596 Y128 E.14735
G1 X125.542 Y128.921 E.14735
G1 X125.378 Y129.83 E.14737
G1 X125.109 Y130.712 E.14735
G1 X124.743 Y131.542 E.14484
G2 X124.226 Y132.411 I33.172 J20.328 E.16136
G1 X123.845 Y132.91 E.10023
G3 X123.063 Y133.753 I-15.03 J-13.161 E.18377
G1 X121.241 Y135.383 E.39029
G1 X121.94 Y136.702 E.23839
G3 X117.99 Y118.376 I-4.126 J-8.699 E5.53902
G3 X121.84 Y119.259 I-.29 J10.104 E.63478
; WIPE_START
G1 X121.271 Y120.636 E-.5662
G1 X121.65 Y120.977 E-.1938
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.453 Y119.707 Z26 F42000
G1 Z25.6
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
M73 P93 R1
G1 X124.614 Y119.75 E.02666
G2 X125.051 Y119.841 I1.407 J-5.653 E.07125
G3 X126.351 Y120.218 I-1.675 J8.208 E.21634
G3 X126.687 Y120.4 I-17.599 J32.857 E.06107
G1 X126.759 Y120.513 E.02133
G3 X127.425 Y121.28 I-3.977 J4.122 E.16242
G2 X128.247 Y122.645 I63.23 J-37.158 E.25437
G1 X128.806 Y123.915 E.22162
G1 X129.212 Y125.244 E.22195
G1 X129.458 Y126.613 E.222
G1 X129.541 Y128 E.22195
G1 X129.458 Y129.388 E.22196
G1 X129.212 Y130.756 E.222
G1 X128.806 Y132.086 E.22196
G1 X128.247 Y133.356 E.22156
G2 X127.4 Y134.755 I53.32 J33.209 E.26116
G3 X126.767 Y135.484 I-4.366 J-3.154 E.15451
G3 X126.562 Y135.683 I-.502 J-.313 E.04601
G3 X124.69 Y136.229 I-3.107 J-7.172 E.31209
G3 X124.284 Y136.305 I-.8 J-3.121 E.06597
G2 X123.05 Y136.899 I3.104 J8.036 E.21894
G3 X118.005 Y117.676 I-5.24 J-8.898 E6.08868
G3 X123.276 Y119.235 I-.264 J10.585 E.88779
G2 X123.975 Y119.551 I2.745 J-5.138 E.12267
G1 X124.339 Y119.67 E.06111
; WIPE_START
M204 S6000
G1 X124.614 Y119.75 E-.109
G1 X125.051 Y119.841 E-.16952
G1 X125.784 Y120.019 E-.28643
G1 X126.268 Y120.189 E-.19505
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


G1 X119.729 Y126.427 F42000
G1 Z25.6
G1 E.8 F1800
; FEATURE: Sparse infill
G1 F3215.099
M204 S6000
G2 X117.213 Y125.591 I-1.922 J1.577 E.44659
G1 X115.398 Y127.406 E.4098
G2 X115.398 Y128.594 I2.411 J.594 E.1917
G1 X117.215 Y130.411 E.41024
G2 X119.731 Y129.571 I.591 J-2.417 E.44664
M204 S10000
G1 X120.506 Y131.98 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.254
G1 F1984.436
M204 S6000
G1 X120.468 Y131.98 E.00997
; LINE_WIDTH: 1.21537
G1 F2054.438
G1 X120.429 Y131.98 E.00963
; LINE_WIDTH: 1.17673
G1 F2129.559
G1 X120.391 Y131.981 E.00929
; LINE_WIDTH: 1.13332
G1 F2220.822
G1 X120.294 Y132.007 E.02323
; LINE_WIDTH: 1.08511
G1 F2331.762
G1 X120.197 Y132.033 E.02213
; LINE_WIDTH: 1.03691
G1 F2454.369
G1 X120.1 Y132.059 E.02102
; LINE_WIDTH: 0.988707
G1 F2590.584
G1 X120.003 Y132.085 E.01992
; LINE_WIDTH: 0.940504
G1 F2742.808
G1 X119.906 Y132.111 E.01881
; LINE_WIDTH: 0.892301
G1 F2914.039
G1 X119.809 Y132.137 E.01771
; LINE_WIDTH: 0.820129
G1 F3214.508
G2 X119.322 Y132.321 I.508 J2.082 E.08331
G1 X118.683 Y132.493 E.10559
G3 X119.733 Y123.847 I-.87 J-4.492 E2.75162
; LINE_WIDTH: 0.84359
G1 F3110.257
G1 X119.804 Y123.86 E.01198
; LINE_WIDTH: 0.890776
G1 F2919.807
G1 X119.876 Y123.873 E.01276
; LINE_WIDTH: 0.937962
G1 F2751.334
G1 X119.947 Y123.886 E.01354
; LINE_WIDTH: 0.985148
G1 F2601.243
G1 X120.018 Y123.899 E.01432
; LINE_WIDTH: 1.03233
G1 F2466.681
G1 X120.09 Y123.912 E.0151
; LINE_WIDTH: 1.07952
G1 F2345.355
G1 X120.161 Y123.925 E.01589
; LINE_WIDTH: 1.12671
G1 F2235.405
G1 X120.233 Y123.938 E.01667
; LINE_WIDTH: 1.17389
G1 F2135.302
G1 X120.304 Y123.951 E.01745
; LINE_WIDTH: 1.22108
G1 F2043.781
G1 X120.375 Y123.964 E.01823
; LINE_WIDTH: 1.26826
G1 F1959.782
G1 X120.447 Y123.976 E.01901
G1 X120.412 Y123.913 E.01901
; LINE_WIDTH: 1.22108
G1 F2043.781
G1 X120.376 Y123.85 E.01823
; LINE_WIDTH: 1.17389
G1 F2135.302
G1 X120.341 Y123.786 E.01745
; LINE_WIDTH: 1.12671
G1 F2235.405
G1 X120.306 Y123.723 E.01667
; LINE_WIDTH: 1.07952
G1 F2345.355
G1 X120.271 Y123.659 E.01589
; LINE_WIDTH: 1.03233
G1 F2466.681
G1 X120.235 Y123.596 E.01511
; LINE_WIDTH: 0.985148
G1 F2601.243
G1 X120.2 Y123.532 E.01432
; LINE_WIDTH: 0.937962
G1 F2751.334
G1 X120.165 Y123.469 E.01354
; LINE_WIDTH: 0.890776
G1 F2919.807
G1 X120.13 Y123.405 E.01276
; LINE_WIDTH: 0.820058
G1 F3214.833
G1 X120.094 Y123.342 E.01159
G1 X118.799 Y122.178 E.27809
G1 X118.509 Y121.841 E.07096
G1 X118.319 Y121.456 E.06857
G1 X118.289 Y121.202 E.04081
G1 X117.447 Y121.192 E.13435
G2 X116.325 Y121.343 I.618 J8.855 E.1809
G1 X115.384 Y121.623 E.1569
G2 X111.084 Y126.945 I2.434 J6.364 E1.14452
G1 X110.995 Y127.592 E.10433
G2 X111.708 Y131.056 I7.039 J.355 E.57078
G2 X118.237 Y134.805 I6.114 J-3.087 E1.27291
G1 X118.328 Y134.442 E.05971
G1 X118.481 Y134.165 E.05058
G1 X118.786 Y133.823 E.07321
G1 X120.073 Y132.672 E.2756
; LINE_WIDTH: 0.844098
G1 F3108.072
G1 X120.129 Y132.589 E.01653
; LINE_WIDTH: 0.892301
G1 F2914.039
G1 X120.186 Y132.507 E.01763
; LINE_WIDTH: 0.940504
G1 F2742.808
G1 X120.242 Y132.424 E.01873
; LINE_WIDTH: 0.988707
G1 F2590.584
G1 X120.298 Y132.341 E.01983
; LINE_WIDTH: 1.03691
G1 F2454.369
G1 X120.355 Y132.259 E.02093
; LINE_WIDTH: 1.08511
G1 F2331.762
G1 X120.411 Y132.176 E.02204
; LINE_WIDTH: 1.13332
G1 F2220.822
G1 X120.468 Y132.093 E.02313
M204 S10000
G1 X124.188 Y128.095 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G2 X122.724 Y123.941 I-6.424 J-.071 E.71782
G1 X122.083 Y123.248 E.15075
G1 X119.735 Y121.137 E.50416
G3 X119.621 Y120.841 I.234 J-.26 E.05257
G1 X119.986 Y120.074 E.13561
G2 X116.239 Y119.925 I-2.204 J8.255 E.60379
G2 X109.762 Y126.291 I1.572 J8.078 E1.53605
G1 X109.598 Y127.472 E.19038
G2 X119.33 Y136.084 I8.228 J.506 E2.38999
M73 P94 R1
G1 X119.944 Y135.924 E.10118
G1 X119.619 Y135.312 E.11052
G1 X119.58 Y135.122 E.03099
G1 X119.639 Y134.952 E.02885
G3 X122.087 Y132.748 I72.78 J78.39 E.5259
G1 X122.772 Y132.009 E.16099
G2 X124.181 Y128.215 I-4.969 J-4.004 E.6576
M204 S10000
G1 X123.49 Y128.054 F42000
G1 F3215.112
M204 S6000
G2 X123.153 Y126.072 I-6.316 J.054 E.32233
G1 X122.937 Y125.567 E.08772
G1 X122.517 Y124.822 E.13658
G1 X122.211 Y124.416 E.08112
G1 X121.591 Y123.747 E.14563
G1 X119.267 Y121.657 E.49903
G1 X119.061 Y121.403 E.05236
G1 X118.979 Y121.224 E.03131
G1 X118.925 Y120.769 E.07317
G1 X118.983 Y120.572 E.0328
G1 X118.004 Y120.481 E.15701
G2 X116.164 Y120.662 I.039 J9.832 E.29566
G1 X115.163 Y120.959 E.16683
G2 X110.449 Y126.427 I2.706 J7.098 E1.20121
G1 X110.297 Y127.532 E.17805
G2 X118.957 Y135.429 I7.519 J.452 E2.1443
G1 X118.882 Y135.07 E.05848
G1 X119.025 Y134.614 E.07634
G1 X119.253 Y134.344 E.05638
G1 X121.596 Y132.249 E.50195
G1 X122.236 Y131.558 E.15042
G1 X122.711 Y130.851 E.1359
G1 X122.974 Y130.35 E.09044
G1 X123.247 Y129.622 E.12412
G1 X123.384 Y129.059 E.0925
G2 X123.483 Y128.173 I-7.349 J-1.27 E.14236
M204 S10000
G1 X121.688 Y128.071 F42000
; LINE_WIDTH: 0.819997
G1 F3215.114
M204 S6000
G1 X121.605 Y128.796 E.11652
G3 X121.229 Y129.84 I-6.336 J-1.693 E.17734
G1 X120.832 Y130.431 E.11368
G3 X119.971 Y131.22 I-4.218 J-3.735 E.18691
G1 X119.373 Y131.551 E.10905
G1 X118.501 Y131.818 E.14563
G1 X117.587 Y131.874 E.14625
G3 X116.539 Y131.673 I.803 J-7.012 E.17048
G1 X115.85 Y131.349 E.12154
G3 X114.936 Y130.61 I3.006 J-4.651 E.18812
G1 X114.528 Y130.073 E.10763
G1 X114.402 Y129.859 E.03968
G1 X114.132 Y129.244 E.10717
G3 X113.929 Y128.094 I5.56 J-1.578 E.18682
G1 X113.971 Y127.423 E.1074
G3 X114.316 Y126.309 I5.661 J1.143 E.18646
G1 X114.66 Y125.732 E.10729
G1 X115.151 Y125.187 E.1172
G1 X115.47 Y124.903 E.06813
G1 X116.046 Y124.544 E.10837
G1 X116.863 Y124.241 E.13925
G1 X117.153 Y124.176 E.04745
G1 X117.803 Y124.12 E.10404
G1 X118.345 Y124.154 E.08675
G1 X119.159 Y124.363 E.1343
G1 X119.99 Y124.793 E.14937
G1 X120.673 Y125.383 E.1441
G3 X121.272 Y126.239 I-5.654 J4.592 E.16689
G1 X121.552 Y126.98 E.12651
G3 X121.678 Y127.951 I-5.803 J1.247 E.15659
M204 S10000
G1 X120.988 Y127.971 F42000
G1 F3215.114
M204 S6000
G1 X120.91 Y128.715 E.11956
G1 X120.655 Y129.426 E.12058
G1 X120.252 Y130.039 E.11708
G3 X119.633 Y130.608 I-5.975 J-5.886 E.13437
G1 X119.035 Y130.938 E.10906
G1 X118.318 Y131.142 E.11891
G1 X117.566 Y131.174 E.12028
G1 X116.829 Y131.029 E.11997
G1 X116.152 Y130.717 E.11903
G3 X115.493 Y130.186 I4.603 J-6.377 E.13522
G1 X115.085 Y129.649 E.10763
G1 X114.773 Y128.963 E.12032
G1 X114.632 Y128.221 E.12068
G1 X114.669 Y127.467 E.12058
G1 X114.883 Y126.743 E.12041
G1 X115.261 Y126.09 E.12044
G3 X115.841 Y125.497 I5.672 J4.962 E.13261
G1 X116.416 Y125.137 E.10837
G1 X117.084 Y124.905 E.1128
G1 X117.696 Y124.832 E.0985
G1 X118.28 Y124.851 E.09333
G1 X118.972 Y125.037 E.11441
G1 X119.648 Y125.404 E.12284
G1 X120.199 Y125.898 E.11808
G1 X120.626 Y126.518 E.12026
G1 X120.895 Y127.222 E.12024
G1 X120.973 Y127.852 E.10135
M204 S10000
G1 X120.447 Y123.976 F42000
; LINE_WIDTH: 1.26864
G1 F1959.145
M204 S6000
G1 X120.95 Y124.398 E.17189
; LINE_WIDTH: 1.22654
G1 F2033.692
G3 X122.548 Y128.565 I-3.161 J3.602 E1.17199
G3 X122.284 Y129.663 I-3.637 J-.295 E.28628
G1 X122.075 Y130.164 E.13696
G3 X120.955 Y131.596 I-4.984 J-2.74 E.46093
; LINE_WIDTH: 1.26004
G1 F1973.927
G1 X120.598 Y131.902 E.12234
M204 S10000
G1 X118.285 Y122.705 F42000
; LINE_WIDTH: 0.892434
G1 F2913.539
M204 S6000
G1 X117.894 Y122.247 E.10612
G1 X117.725 Y121.922 E.06469
G2 X115.616 Y122.323 I.211 J6.842 E.37971
G2 X111.781 Y127.257 I2.186 J5.658 E1.15683
G2 X112.099 Y130.098 I5.926 J.773 E.50874
G2 X117.688 Y134.087 I5.718 J-2.103 E1.28504
G1 X117.875 Y133.753 E.06741
G1 X118.273 Y133.298 E.1066
G3 X114.205 Y131.902 I-.414 J-5.422 E.77919
G3 X112.685 Y129.432 I3.847 J-4.068 E.51696
G1 X112.529 Y128.593 E.15028
G3 X112.644 Y126.753 I6.195 J-.534 E.32602
G3 X114.122 Y124.182 I5.137 J1.242 E.52967
G3 X114.954 Y123.529 I2.543 J2.382 E.18718
G1 X115.443 Y123.236 E.10025
G1 X116.411 Y122.877 E.18202
G3 X117.515 Y122.702 I1.206 J4.059 E.19746
G1 X118.166 Y122.694 E.11473
; WIPE_START
G1 X117.515 Y122.702 E-.24743
G1 X116.906 Y122.761 E-.23226
G1 X116.411 Y122.877 E-.19326
G1 X116.196 Y122.956 E-.08705
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.767 Y128.173 Z26 F42000
G1 X127.695 Y133.724 Z26
G1 Z25.6
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.846707
G1 F3096.913
M204 S2000
G1 X126.26 Y135.159 E.33641
G3 X125.858 Y135.32 I-.679 J-1.105 E.07206
G3 X125.202 Y135.505 I-1.056 J-2.488 E.1134
G3 X124.792 Y135.6 I-.654 J-1.901 E.06978
G1 X128.038 Y132.353 E.76103
G1 X128.248 Y131.878 E.08608
G1 X128.583 Y130.782 E.19003
G1 X123.269 Y136.096 E1.24572
G2 X122.514 Y136.515 I16.381 J30.338 E.14311
G1 X122.274 Y136.062 E.08494
G1 X128.833 Y129.504 E1.53756
G1 X128.867 Y129.317 E.03141
G1 X128.922 Y128.388 E.15438
G1 X124.944 Y132.365 E.93247
G3 X125.272 Y131.818 I21.146 J12.289 E.10572
G1 X125.667 Y130.92 E.16271
G1 X125.802 Y130.48 E.07618
G1 X128.908 Y127.374 E.72814
G1 X128.867 Y126.683 E.11477
G1 X128.822 Y126.433 E.04216
G1 X126.105 Y129.149 E.63686
G1 X126.133 Y128.992 E.02652
G1 X126.19 Y128.037 E.15859
G1 X128.665 Y125.562 E.58024
G1 X128.633 Y125.384 E.02994
G1 X128.442 Y124.758 E.10858
G1 X126.137 Y127.063 E.54043
G2 X125.986 Y126.187 I-9.058 J1.109 E.14749
G1 X128.187 Y123.985 E.51614
G1 X127.873 Y123.272 E.1292
G1 X125.76 Y125.384 E.49532
G2 X125.474 Y124.643 I-3.257 J.828 E.13208
G1 X127.522 Y122.595 E.47994
G1 X127.134 Y121.955 E.12402
G1 X125.134 Y123.955 E.46882
G3 X124.753 Y123.309 I30.516 J-18.466 E.12436
G1 X126.716 Y121.347 E.46015
G1 X126.285 Y120.876 E.10568
G2 X126.215 Y120.819 I-.078 J.025 E.01581
G1 X124.312 Y122.723 E.44615
G1 X123.822 Y122.185 E.12056
G1 X125.454 Y120.553 E.38258
G2 X124.617 Y120.363 I-4.117 J16.131 E.14228
G1 X123.31 Y121.669 E.30639
G1 X122.769 Y121.183 E.1206
G1 X123.817 Y120.135 E.2456
G3 X123.106 Y119.818 I2.03 J-5.508 E.12907
G1 X122.005 Y120.919 E.25812
; CHANGE_LAYER
; Z_HEIGHT: 26.16
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3096.913
M204 S6000
G1 X123.106 Y119.818 E-.5917
G1 X123.333 Y119.939 E-.09743
G1 X123.506 Y120.009 E-.07087
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 47/51
; update layer progress
M73 L47
M991 S0 P46 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z26.16 I-1.473 J-.856 P1  F42000
G1 X121.141 Y124.076 Z26.16
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X121.284 Y124.196 E.02997
G3 X117.352 Y122.862 I-3.481 J3.799 E4.48748
G3 X118.56 Y122.898 I.454 J5.054 E.19341
G3 X120.809 Y123.81 I-.757 J5.097 E.39109
G1 X121.047 Y124.001 E.04879
M204 S10000
G1 X121.581 Y123.532 F42000
G1 F3215.099
M204 S6000
G1 X121.759 Y123.676 E.03656
G3 X116.592 Y122.27 I-3.951 J4.322 E4.98663
G3 X118.663 Y122.205 I1.236 J6.361 E.33222
G3 X121.218 Y123.238 I-.855 J5.793 E.44424
G1 X121.488 Y123.456 E.05544
; WIPE_START
G1 X121.759 Y123.676 E-.13259
G1 X122.247 Y124.176 E-.26555
G1 X122.666 Y124.726 E-.26278
G1 X122.799 Y124.951 E-.09908
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.003 Y120.418 Z26.56 F42000
G1 Z26.16
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X124.079 Y120.467 E.01439
G3 X125.392 Y121.806 I-8.141 J9.3 E.29976
G1 X125.903 Y122.475 E.13445
G2 X126.529 Y123.526 I48.418 J-28.094 E.19531
G1 X126.996 Y124.587 E.18509
G1 X127.335 Y125.698 E.18542
G1 X127.541 Y126.841 E.18547
G1 X127.609 Y128 E.18543
G1 X127.541 Y129.159 E.18542
G1 X127.335 Y130.303 E.18547
G1 X126.996 Y131.413 E.18543
G1 X126.529 Y132.474 E.18501
G2 X125.896 Y133.536 I40.505 J24.86 E.19738
G1 X125.388 Y134.201 E.13369
G3 X124.081 Y135.532 I-9.995 J-8.507 E.29811
G3 X121.892 Y136.8 I-10.464 J-15.548 E.40422
G3 X109.438 Y132.905 I-4.083 J-8.803 E2.285
G2 X109.168 Y132.411 I-1.021 J.237 E.09117
G3 X108.157 Y128.984 I9.01 J-4.519 E.57355
G2 X108.107 Y128.102 I-3.15 J-.265 E.1415
G3 X115.57 Y118.561 I9.702 J-.1 E2.08876
G2 X116.095 Y118.456 I.077 J-.974 E.08648
G3 X118.175 Y118.306 I1.83 J10.925 E.33351
G3 X123.076 Y119.847 I-.388 J9.799 E.82999
G3 X123.377 Y120.022 I-7.538 J13.318 E.05575
G1 X123.902 Y120.354 E.09908
; WIPE_START
M204 S6000
G1 X124.079 Y120.467 E-.07984
G1 X124.455 Y120.796 E-.18984
G1 X125.333 Y121.742 E-.49033
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


G1 X125.995 Y123.18 F42000
G1 Z26.16
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.824027
G1 F3196.704
M204 S2000
G1 X124.015 Y121.201 E.4495
G2 X123.428 Y120.753 I-2.217 J2.301 E.11891
G2 X121.495 Y119.676 I-8.619 J13.191 E.35557
G1 X126.299 Y124.479 E1.09092
G1 X126.438 Y124.795 E.05535
G1 X126.756 Y125.838 E.17516
G1 X126.777 Y125.953 E.01876
G1 X119.982 Y119.158 E1.54321
G2 X118.776 Y118.947 I-2.148 J8.738 E.19678
G1 X126.962 Y127.134 E1.85927
G1 X127.014 Y128 E.1394
G1 X127.004 Y128.17 E.02738
G1 X117.728 Y118.895 E2.10652
G2 X116.791 Y118.953 I.452 J14.926 E.15087
G1 X119.663 Y121.826 E.65239
G1 X119.51 Y121.774 E.02606
G1 X118.75 Y121.616 E.12455
G1 X118.429 Y121.587 E.0518
G1 X115.971 Y119.129 E.55832
G1 X115.953 Y119.135 E.003
G2 X115.235 Y119.265 I0 J2.042 E.11778
G1 X115.141 Y119.294 E.01584
G1 X117.412 Y121.565 E.51578
G1 X117.235 Y121.571 E.02844
G1 X116.529 Y121.678 E.11467
G1 X114.406 Y119.554 E.48236
M73 P94 R0
G2 X113.719 Y119.863 I6.881 J16.177 E.12087
G1 X115.743 Y121.887 E.45953
G1 X115.035 Y122.174 E.12274
G1 X113.08 Y120.22 E.44381
G2 X112.481 Y120.615 I7.048 J11.332 E.1154
G1 X114.391 Y122.526 E.43387
G1 X113.809 Y122.939 E.11466
G1 X111.923 Y121.053 E.42826
G2 X111.403 Y121.529 I5.426 J6.448 E.11318
G1 X113.283 Y123.408 E.4269
G1 X113.165 Y123.517 E.02574
G1 X112.809 Y123.93 E.08755
G1 X110.922 Y122.043 E.42859
G2 X110.479 Y122.596 I10.915 J9.192 E.11373
G1 X112.391 Y124.507 E.4342
G2 X112.031 Y125.143 I2.486 J1.828 E.11756
G1 X110.078 Y123.189 E.4437
G2 X109.717 Y123.824 I8.575 J5.289 E.11727
G1 X111.735 Y125.842 E.45834
G2 X111.513 Y126.615 I3.133 J1.319 E.1295
G1 X109.401 Y124.503 E.47973
G2 X109.134 Y125.231 I12.678 J5.065 E.12458
G1 X111.381 Y127.478 E.51033
G1 X111.364 Y127.618 E.02255
G1 X111.374 Y128.467 E.13641
G1 X108.923 Y126.016 E.55665
G2 X108.773 Y126.862 I10.191 J2.243 E.13793
G1 X112.072 Y130.161 E.74929
; WIPE_START
M204 S6000
G1 X110.658 Y128.747 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.072 Y126.931 Z26.56 F42000
G1 X123.452 Y125.614 Z26.56
G1 Z26.16
G1 E.8 F1800
G1 F3196.704
M204 S2000
G1 X126.946 Y129.108 E.79348
G1 X126.794 Y129.952 E.13767
G1 X124.224 Y127.382 E.58371
G3 X124.238 Y128.391 I-4.265 J.565 E.16253
G1 X126.581 Y130.734 E.5322
G3 X126.321 Y131.47 I-3.217 J-.725 E.12554
G1 X124.124 Y129.273 E.49898
G3 X123.915 Y130.059 I-3.4 J-.485 E.13093
G1 X126.017 Y132.161 E.47742
G3 X125.648 Y132.787 I-18.955 J-10.76 E.11674
G1 X123.629 Y130.768 E.45845
G3 X123.277 Y131.411 I-2.843 J-1.14 E.11804
G1 X125.257 Y133.392 E.44988
G3 X124.816 Y133.946 I-3.291 J-2.175 E.11389
G1 X122.864 Y131.994 E.4432
G3 X122.397 Y132.522 I-2.471 J-1.718 E.1135
G1 X124.34 Y134.465 E.44128
G3 X123.837 Y134.958 I-12.693 J-12.413 E.11305
G1 X121.875 Y132.996 E.44567
G3 X121.299 Y133.416 I-2.079 J-2.248 E.11468
G1 X123.246 Y135.362 E.44214
G3 X122.624 Y135.736 I-13.316 J-21.489 E.11652
G1 X120.665 Y133.777 E.44493
G3 X119.965 Y134.072 I-1.567 J-2.736 E.1223
G1 X121.985 Y136.091 E.45864
G3 X121.304 Y136.406 I-4.814 J-9.513 E.12045
G1 X119.19 Y134.293 E.48003
M73 P95 R0
G3 X118.324 Y134.422 I-.975 J-3.57 E.14097
G1 X120.577 Y136.674 E.51157
G3 X119.793 Y136.886 I-3.521 J-11.45 E.13035
G1 X117.34 Y134.433 E.55727
G1 X116.479 Y134.317 E.13948
G1 X116.133 Y134.222 E.0576
G1 X118.946 Y137.035 E.63892
G3 X118.019 Y137.103 I-1.392 J-12.596 E.14935
G1 X108.704 Y127.788 E2.11556
G2 X108.743 Y128.265 I1.803 J.095 E.07715
G1 X108.763 Y128.842 E.09272
G1 X116.989 Y137.069 E1.8683
G3 X115.809 Y136.884 I1.06 J-10.625 E.19197
G1 X108.924 Y129.999 E1.56368
G2 X109.381 Y131.451 I10.767 J-2.591 E.24477
G1 X114.354 Y136.424 E1.12938
G3 X111.549 Y134.615 I3.434 J-8.402 E.53905
G1 X109.676 Y132.741 E.42557
; WIPE_START
M204 S6000
G1 X111.09 Y134.155 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X115.791 Y132.435 Z26.56 F42000
G1 Z26.16
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.821497
G1 F3208.236
M204 S6000
G1 X114.536 Y131.179 E.28411
G3 X113.369 Y129.021 I3.37 J-3.217 E.39737
G1 X116.791 Y132.443 E.77451
G2 X117.899 Y132.559 I1.096 J-5.143 E.17848
G1 X113.253 Y127.913 E1.05122
G1 X113.253 Y127.73 E.02933
G1 X113.317 Y127.193 E.08663
G1 X113.358 Y127.026 E.02743
G1 X118.78 Y132.448 E1.22705
G2 X119.525 Y132.227 I-.564 J-3.259 E.12463
G1 X119.542 Y132.218 E.00306
G1 X113.592 Y126.269 E1.3464
G1 X113.632 Y126.161 E.01835
G1 X113.926 Y125.611 E.09986
G1 X120.194 Y131.879 E1.41844
G2 X120.768 Y131.461 I-1.496 J-2.658 E.11386
G1 X114.347 Y125.04 E1.4531
G3 X114.841 Y124.542 I2.392 J1.883 E.11247
G1 X121.269 Y130.97 E1.45446
G1 X121.593 Y130.547 E.08523
G1 X121.684 Y130.393 E.02863
G1 X115.412 Y124.121 E1.41932
G3 X116.073 Y123.791 I1.745 J2.67 E.1186
G1 X122.019 Y129.736 E1.34537
G1 X122.081 Y129.593 E.02497
G1 X122.257 Y128.982 E.10169
G1 X116.824 Y123.549 E1.22948
G3 X117.713 Y123.447 I1.091 J5.58 E.14344
G1 X122.363 Y128.096 E1.0522
G2 X122.253 Y126.995 I-5.452 J-.012 E.17751
G1 X118.818 Y123.56 E.77728
G3 X120.881 Y124.631 I-1.043 J4.531 E.37591
G1 X122.242 Y125.992 E.30793
; CHANGE_LAYER
; Z_HEIGHT: 26.72
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F3208.236
G1 X120.881 Y124.631 E-.73127
G1 X120.822 Y124.583 E-.02873
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 48/51
; update layer progress
M73 L48
M991 S0 P47 ;notify layer change
M106 S201.45
; OBJECT_ID: 15
M204 S10000
G17
G3 Z26.72 I-1.297 J-1.105 P1  F42000
G1 X119.959 Y125.596 Z26.72
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F3215.099
M204 S6000
G1 X120.001 Y125.631 E.00869
G3 X117.913 Y124.773 I-2.192 J2.368 E2.86916
G1 X118.298 Y124.809 E.06173
G3 X119.702 Y125.385 I-.49 J3.189 E.24449
G1 X119.866 Y125.52 E.03396
M204 S10000
G1 X120.402 Y125.055 F42000
G1 F3215.099
M204 S6000
G1 X120.474 Y125.116 E.01504
G3 X117.01 Y124.152 I-2.667 J2.881 E3.34268
G3 X118.403 Y124.116 I.816 J4.563 E.22333
G3 X120.112 Y124.818 I-.596 J3.881 E.29785
G1 X120.309 Y124.979 E.04061
; WIPE_START
G1 X120.474 Y125.116 E-.08138
G1 X120.785 Y125.435 E-.1695
G1 X121.067 Y125.806 E-.17688
G1 X121.288 Y126.178 E-.16445
G1 X121.469 Y126.581 E-.16779
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X122.894 Y122.009 Z27.12 F42000
G1 Z26.72
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3215.099
M204 S5000
G1 X123.116 Y122.189 E.04558
G3 X123.791 Y122.887 I-6.082 J6.555 E.1552
G3 X124.354 Y123.631 I-6.674 J5.635 E.14901
G1 X124.808 Y124.403 E.14298
G1 X125.185 Y125.257 E.14908
G1 X125.458 Y126.15 E.14908
G3 X125.623 Y127.062 I-15.043 J3.189 E.14806
G1 X125.678 Y128.018 E.15293
G1 X125.623 Y128.932 E.14612
G1 X125.458 Y129.851 E.14909
G1 X125.185 Y130.744 E.14909
G1 X124.825 Y131.564 E.14296
G3 X116.213 Y135.708 I-7.026 J-3.58 E1.63953
G3 X113.592 Y134.647 I1.884 J-8.421 E.45349
G1 X112.867 Y134.127 E.14248
G3 X111.54 Y132.761 I6.098 J-7.251 E.30462
G3 X111.025 Y131.995 I6.744 J-5.087 E.1474
G1 X110.6 Y131.164 E.14904
G1 X110.286 Y130.319 E.14404
G3 X110.058 Y129.381 I59.224 J-14.869 E.15403
G1 X109.949 Y128.454 E.14902
G1 X109.949 Y127.546 E.14501
G1 X110.063 Y126.595 E.15303
G3 X112.81 Y121.921 I7.796 J1.439 E.88345
G1 X112.867 Y121.873 E.01183
G3 X114.408 Y120.901 I5.055 J6.309 E.29163
G1 X115.273 Y120.548 E.14916
G1 X116.173 Y120.301 E.14907
G3 X117.136 Y120.158 I2.04 J10.445 E.15543
G3 X118.068 Y120.134 I.738 J10.398 E.14901
G1 X118.959 Y120.214 E.14273
G3 X119.91 Y120.416 I-1.574 J9.767 E.15541
G3 X120.793 Y120.718 I-2.705 J9.341 E.14907
G1 X121.6 Y121.103 E.14275
G1 X122.39 Y121.601 E.1491
G1 X122.801 Y121.934 E.08437
; WIPE_START
M204 S6000
G1 X123.116 Y122.189 E-.15407
G1 X123.791 Y122.887 E-.36917
G1 X124.167 Y123.384 E-.23676
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


G1 X118.183 Y127.953 F42000
G1 Z26.72
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.875847
G1 F2977.49
M204 S6000
G1 X118.125 Y127.784 E.03078
G1 X117.945 Y127.646 E.03922
G1 X117.731 Y127.627 E.03702
G1 X117.534 Y127.732 E.03861
G1 X117.433 Y127.933 E.03882
G1 X117.453 Y128.146 E.03676
G1 X117.606 Y128.323 E.04033
G1 X117.82 Y128.383 E.03844
G1 X118.04 Y128.301 E.04038
G1 X118.17 Y128.131 E.03693
G1 X118.174 Y128.073 E.01
M204 S10000
G1 X118.911 Y127.98 F42000
; LINE_WIDTH: 0.819997
G1 F3215.112
M204 S6000
G1 X118.856 Y127.614 E.05909
G1 X118.652 Y127.28 E.06254
G1 X118.35 Y127.025 E.06301
G1 X117.968 Y126.903 E.064
G1 X117.734 Y126.882 E.03756
G1 X117.332 Y126.999 E.06691
G1 X117.009 Y127.221 E.0625
G1 X116.793 Y127.554 E.06346
G1 X116.693 Y127.934 E.06265
G1 X116.745 Y128.32 E.06217
G1 X116.924 Y128.683 E.06464
G1 X117.225 Y128.943 E.06357
G1 X117.573 Y129.092 E.0604
G1 X117.991 Y129.093 E.06672
G1 X118.34 Y128.982 E.05854
M73 P96 R0
G1 X118.651 Y128.721 E.06471
G1 X118.856 Y128.387 E.06264
G1 X118.895 Y128.099 E.04641
M204 S10000
G1 X119.61 Y127.953 F42000
G1 F3215.112
M204 S6000
G1 X119.563 Y127.557 E.06368
G2 X118.878 Y126.544 I-1.933 J.568 E.19843
G1 X118.693 Y126.409 E.03649
G1 X118.286 Y126.243 E.07023
G1 X117.756 Y126.178 E.08518
G1 X117.23 Y126.273 E.08545
G1 X116.838 Y126.459 E.06919
G1 X116.504 Y126.729 E.06862
G1 X116.24 Y127.073 E.0692
G1 X116.066 Y127.469 E.0691
G1 X115.99 Y127.892 E.06869
G1 X116.015 Y128.324 E.06909
G1 X116.136 Y128.722 E.06644
G1 X116.363 Y129.11 E.07172
G1 X116.658 Y129.413 E.06756
G1 X117.03 Y129.647 E.07005
G1 X117.429 Y129.782 E.06729
G1 X117.867 Y129.82 E.07031
G1 X118.299 Y129.754 E.06974
G1 X118.682 Y129.598 E.06599
G1 X119.045 Y129.336 E.0715
G1 X119.319 Y129.018 E.06699
G1 X119.516 Y128.633 E.06906
G1 X119.61 Y128.248 E.06326
G1 X119.61 Y128.073 E.02799
M204 S10000
G1 X120.31 Y127.953 F42000
G1 F3215.112
M204 S6000
G1 X120.31 Y127.668 E.04557
G1 X120.176 Y127.121 E.0899
G1 X119.903 Y126.589 E.09551
G1 X119.525 Y126.148 E.09271
G1 X119.036 Y125.794 E.09644
G1 X118.473 Y125.563 E.09713
G1 X117.88 Y125.474 E.09567
G2 X117.005 Y125.605 I.105 J3.692 E.1417
G1 X116.463 Y125.862 E.09567
G1 X115.999 Y126.237 E.09529
G1 X115.634 Y126.714 E.09591
G1 X115.392 Y127.263 E.09581
G1 X115.286 Y127.85 E.09535
G1 X115.322 Y128.448 E.09562
G1 X115.491 Y129.005 E.09289
G1 X115.803 Y129.536 E.09841
G1 X116.214 Y129.961 E.09443
G1 X116.727 Y130.283 E.09667
G1 X117.284 Y130.472 E.09394
G1 X117.89 Y130.524 E.09716
G1 X118.486 Y130.433 E.09629
G1 X119.024 Y130.215 E.09258
G1 X119.521 Y129.855 E.09809
G1 X119.903 Y129.412 E.09343
G1 X120.176 Y128.88 E.09547
G1 X120.31 Y128.333 E.08987
G1 X120.31 Y128.073 E.04149
; WIPE_START
G1 X120.31 Y128.333 E-.09874
G1 X120.176 Y128.88 E-.21389
G1 X119.903 Y129.412 E-.22722
G1 X119.525 Y129.851 E-.22016
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.37 Y134.698 Z27.12 F42000
G1 Z26.72
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.846007
G1 F3099.899
M204 S2000
G1 X123.319 Y132.749 E.45648
G2 X123.852 Y132.05 I-6.059 J-5.174 E.14565
G2 X124.288 Y131.307 I-6.617 J-4.386 E.14279
G1 X124.626 Y130.537 E.1393
G1 X124.68 Y130.361 E.03034
G1 X120.174 Y134.867 E1.05519
G1 X119.717 Y135.02 E.07992
G1 X118.812 Y135.202 E.15278
G1 X125.005 Y129.01 E1.45028
G1 X125.032 Y128.861 E.02504
G1 X125.076 Y127.912 E.15732
G1 X117.724 Y135.264 E1.72189
G3 X116.772 Y135.19 I-.153 J-4.176 E.15851
G1 X125.001 Y126.961 E1.92723
G1 X124.879 Y126.291 E.11288
G1 X124.824 Y126.111 E.03105
G1 X122.281 Y128.654 E.59563
G1 X122.289 Y128.61 E.00751
G2 X122.297 Y128.552 I-.132 J-.049 E.00979
G2 X122.306 Y127.603 I-5.099 J-.523 E.15741
G1 X124.571 Y125.338 E.53033
G1 X124.252 Y124.63 E.12855
G1 X122.146 Y126.736 E.49322
G2 X121.861 Y125.994 I-3.778 J1.024 E.13182
G1 X123.872 Y123.984 E.47078
G2 X123.83 Y123.918 I-.522 J.284 E.01302
G1 X123.432 Y123.397 E.10847
G1 X121.474 Y125.356 E.45871
G2 X121.001 Y124.802 I-2.965 J2.054 E.12078
G1 X122.941 Y122.862 E.45451
G2 X122.401 Y122.375 I-2.331 J2.045 E.12064
G1 X120.442 Y124.322 E.45745
G2 X119.803 Y123.947 I-2.056 J2.77 E.123
G1 X121.811 Y121.939 E.47032
G1 X121.312 Y121.625 E.09758
G1 X121.168 Y121.556 E.02656
G1 X119.067 Y123.656 E.49195
G1 X119.035 Y123.646 E.00557
G2 X118.198 Y123.5 I-1.338 J5.199 E.14098
G1 X120.466 Y121.231 E.53124
G1 X119.696 Y120.975 E.13441
G1 X116.734 Y123.937 E.69377
; WIPE_START
M204 S6000
G1 X118.148 Y122.523 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.718 Y130.134 Z27.12 F42000
G1 X118.863 Y132.072 Z27.12
G1 Z26.72
G1 E.8 F1800
G1 F3099.899
M204 S2000
G1 X115.921 Y135.014 E.68904
G3 X115.15 Y134.759 I.689 J-3.385 E.13491
G1 X117.401 Y132.508 E.52728
G3 X116.543 Y132.339 I.333 J-3.951 E.14503
G1 X114.443 Y134.439 E.49183
G1 X113.91 Y134.144 E.10095
G1 X113.795 Y134.061 E.02349
G1 X115.803 Y132.053 E.47022
G1 X115.419 Y131.843 E.07246
G3 X115.165 Y131.665 I1.042 J-1.756 E.05147
G1 X113.2 Y133.63 E.46025
G1 X112.664 Y133.139 E.12032
G1 X114.607 Y131.196 E.45512
G1 X114.583 Y131.174 E.00547
G3 X114.138 Y130.639 I2.27 J-2.339 E.11545
G1 X112.181 Y132.595 E.4583
G3 X111.746 Y132.004 I2.334 J-2.169 E.12187
G1 X113.754 Y129.996 E.47014
G1 X113.678 Y129.849 E.02741
G3 X113.488 Y129.346 I5.338 J-2.307 E.08909
G3 X113.464 Y129.259 I.466 J-.174 E.0149
G1 X111.366 Y131.357 E.49135
G3 X111.044 Y130.653 I2.797 J-1.703 E.12859
G1 X113.304 Y128.393 E.52934
G1 X113.292 Y128.29 E.01704
G3 X113.337 Y127.333 I5.849 J-.205 E.15885
G1 X110.789 Y129.881 E.59673
G1 X110.646 Y129.288 E.10107
G1 X110.615 Y129.029 E.04321
G1 X118.843 Y120.801 E1.92713
G1 X118.037 Y120.728 E.13401
G2 X117.887 Y120.731 I-.044 J1.701 E.02498
G1 X110.544 Y128.074 E1.71973
G3 X110.614 Y126.977 I4.639 J-.252 E.18248
G1 X116.781 Y120.81 E1.44425
G1 X116.297 Y120.884 E.08101
G1 X115.443 Y121.121 E.14684
G1 X110.942 Y125.623 E1.05418
G3 X111.153 Y125.057 I8.565 J2.88 E.09999
G1 X111.543 Y124.298 E.14128
G1 X112.025 Y123.583 E.14282
G1 X112.465 Y123.073 E.11154
G1 X114.206 Y121.332 E.40784
; CHANGE_LAYER
; Z_HEIGHT: 27.28
; LAYER_HEIGHT: 0.560001
; WIPE_START
G1 F3099.899
M204 S6000
G1 X112.792 Y122.746 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 49/51
; update layer progress
M73 L49
M991 S0 P48 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
G3 Z27.28 I-1.003 J1.377 P1  F42000
G1 X118.596 Y126.974 Z27.28
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.82
G1 F2966
M204 S6000
G1 X118.782 Y127.147 E.04061
G3 X117.844 Y126.702 I-.979 J.851 E1.13117
G1 X117.878 Y126.704 E.00553
G3 X118.499 Y126.904 I-.076 J1.295 E.10516
M204 S10000
G1 X119.031 Y126.42 F42000
G1 F2966
M204 S6000
G1 X119.309 Y126.689 E.0617
G3 X117.853 Y126.002 I-1.507 J1.309 E1.73849
G1 X117.929 Y126.005 E.01218
G3 X118.934 Y126.354 I-.128 J1.992 E.17183
; WIPE_START
G1 F3215.099
G1 X119.309 Y126.689 E-.19114
G1 X119.507 Y126.949 E-.12413
G1 X119.683 Y127.309 E-.15221
G1 X119.779 Y127.677 E-.1447
G1 X119.803 Y128.065 E-.14781
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.71 Y123.538 Z27.68 F42000
G1 Z27.28
G1 E.8 F1800
; FEATURE: Outer wall
G1 F2966
M204 S5000
G1 X121.888 Y123.689 E.03721
G3 X118.662 Y133.879 I-4.086 J4.312 E2.12269
G3 X118.069 Y122.067 I-.845 J-5.878 E3.15488
G3 X121.257 Y123.169 I-.267 J5.934 E.54616
G1 X121.617 Y123.462 E.07408
; WIPE_START
G1 F3215.099
M204 S6000
G1 X121.888 Y123.689 E-.13414
G1 X122.299 Y124.113 E-.2245
G1 X122.729 Y124.673 E-.26829
G1 X122.907 Y124.974 E-.13307
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


G1 X120.262 Y122.908 F42000
G1 Z27.28
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.831827
G1 F2966
M204 S2000
G3 X121.788 Y124.436 I-50.784 J52.269 E.35065
G3 X122.969 Y126.622 I-4.148 J3.652 E.4069
G1 X119.182 Y122.835 E.86954
G2 X117.999 Y122.659 I-1.373 J5.158 E.19458
G1 X123.14 Y127.799 E1.18036
G3 X123.095 Y128.761 I-4.59 J.269 E.15664
G1 X117.05 Y122.716 E1.38821
G2 X116.226 Y122.899 I.454 J3.992 E.13724
G1 X122.907 Y129.58 E1.53423
G3 X122.626 Y130.305 I-4.205 J-1.214 E.12646
G1 X120.399 Y128.078 E.51136
G3 X120.233 Y128.918 I-2.6 J-.078 E.13969
G1 X122.264 Y130.95 E.46651
G3 X121.828 Y131.52 I-7.511 J-5.301 E.11659
G1 X119.874 Y129.566 E.44866
G3 X119.371 Y130.069 I-2.055 J-1.552 E.11592
G1 X121.322 Y132.021 E.44813
G3 X120.75 Y132.454 I-2.372 J-2.537 E.11686
G1 X118.722 Y130.427 E.46564
G1 X118.621 Y130.463 E.01738
G3 X117.882 Y130.593 I-.897 J-2.937 E.12224
G1 X120.343 Y133.054 E.56531
; WIPE_START
G1 F3161.666
M204 S6000
G1 X118.929 Y131.64 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.058 Y125.737 Z27.68 F42000
G1 Z27.28
G1 E.8 F1800
G1 F2966
M204 S2000
G1 X115.5 Y123.179 E.58744
G2 X114.86 Y123.546 I6.307 J11.734 E.11973
G1 X116.89 Y125.576 E.46615
G2 X116.241 Y125.933 I.952 J2.496 E.12069
G1 X114.291 Y123.982 E.44795
G2 X113.789 Y124.487 I2.172 J2.662 E.11576
G1 X115.738 Y126.437 E.44771
G2 X115.382 Y127.087 I2.415 J1.748 E.12067
G1 X113.353 Y125.058 E.4658
G2 X112.988 Y125.699 I2.836 J2.038 E.12005
G1 X115.545 Y128.256 E.58703
; WIPE_START
G1 F3161.666
M204 S6000
G1 X114.131 Y126.842 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X112.456 Y126.173 Z27.68 F42000
G1 Z27.28
G1 E.8 F1800
G1 F2966
M204 S2000
G1 X119.385 Y133.102 E1.59112
G3 X118.566 Y133.29 I-2.131 J-7.406 E.13643
G1 X112.522 Y127.246 E1.38802
G2 X112.47 Y128.2 I4.318 J.715 E.15549
G1 X117.604 Y133.334 E1.17899
G3 X116.418 Y133.155 I.264 J-5.749 E.19514
G1 X112.651 Y129.388 E.86487
G2 X113.907 Y131.65 I5.307 J-1.466 E.42403
G1 X115.361 Y133.105 E.33393
; WIPE_START
G1 F3161.666
M204 S6000
G1 X113.947 Y131.69 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.283 Y128.014 Z27.68 F42000
G1 Z27.28
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 1.04333
G1 F2437.295
M204 S6000
G2 X118.172 Y127.695 I-.672 J.055 E.07183
G1 X117.912 Y127.543 E.06346
G1 X117.664 Y127.547 E.05235
G1 X117.417 Y127.738 E.06571
G1 X117.33 Y127.978 E.05386
G1 X117.393 Y128.204 E.04931
G1 X117.54 Y128.388 E.04967
G1 X117.779 Y128.476 E.05367
G1 X118.025 Y128.408 E.05379
G1 X118.187 Y128.274 E.04429
G1 X118.242 Y128.126 E.0332
; CHANGE_LAYER
; Z_HEIGHT: 27.84
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2437.295
G1 X118.187 Y128.274 E-.0599
G1 X118.025 Y128.408 E-.0799
G1 X117.779 Y128.476 E-.09703
G1 X117.54 Y128.388 E-.09683
G1 X117.393 Y128.204 E-.08961
G1 X117.33 Y127.978 E-.08896
G1 X117.417 Y127.738 E-.09717
G1 X117.664 Y127.547 E-.11855
G1 X117.748 Y127.546 E-.03207
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 50/51
; update layer progress
M73 L50
M991 S0 P49 ;notify layer change
; OBJECT_ID: 15
M204 S10000
G17
M73 P97 R0
G3 Z27.84 I1.136 J1.27 P1  F42000
G1 X120.53 Y125.058 Z27.84
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.82
G1 F1267
M204 S5000
G1 X120.637 Y125.161 E.02371
G3 X118.356 Y131.972 I-2.831 J2.839 E1.42118
G3 X118.075 Y124 I-.542 J-3.972 E2.13938
G3 X120.44 Y124.978 I-.269 J4 E.41603
; WIPE_START
G1 F3215.099
M204 S6000
G1 X120.637 Y125.161 E-.10199
G1 X120.829 Y125.365 E-.10665
G1 X121.123 Y125.745 E-.18222
G1 X121.368 Y126.158 E-.18246
G1 X121.454 Y126.334 E-.07463
G1 X121.563 Y126.595 E-.10735
G1 X121.566 Y126.607 E-.00471
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


G1 X121.305 Y129.293 F42000
G1 Z27.84
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.872927
G1 F1267
M204 S2000
G1 X119.904 Y130.695 E.34048
G3 X118.137 Y131.396 I-2.093 J-2.696 E.33076
G1 X121.203 Y128.33 E.74473
G2 X121.15 Y127.319 I-3.762 J-.309 E.17447
G1 X117.124 Y131.345 E.97784
G3 X116.328 Y131.077 I.749 J-3.543 E.14467
G1 X120.883 Y126.521 E1.10647
G2 X120.471 Y125.869 I-2.959 J1.413 E.13285
G1 X115.675 Y130.665 E1.16502
G3 X115.142 Y130.133 I2.328 J-2.864 E.12951
G1 X119.94 Y125.336 E1.1653
G2 X119.287 Y124.924 I-2.221 J2.802 E.13284
G1 X114.731 Y129.48 E1.10646
G3 X114.462 Y128.684 I3.116 J-1.496 E.14462
G1 X118.49 Y124.657 E.97818
G2 X117.48 Y124.602 I-.715 J3.861 E.17419
G1 X114.41 Y127.671 E.74551
G3 X114.476 Y127.258 I3.137 J.288 E.0719
G3 X115.115 Y125.902 I3.524 J.832 E.25938
G1 X116.513 Y124.504 E.33943
; CHANGE_LAYER
; Z_HEIGHT: 28.4
; LAYER_HEIGHT: 0.559999
; WIPE_START
G1 F2989.04
M204 S6000
G1 X115.115 Y125.902 E-.75099
G1 X115.102 Y125.921 E-.00901
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 51/51
; update layer progress
M73 L51
M991 S0 P50 ;notify layer change
M106 S204
; OBJECT_ID: 15
M204 S10000
G17
G3 Z28.4 I-.444 J1.645 P1  F42000
G1 X118.836 Y126.929 Z28.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.82
G1 F1200
M204 S5000
G1 X118.977 Y127.078 E.03277
G3 X119.307 Y127.859 I-1.19 J.962 E.13711
G2 X119.307 Y128.142 I.342 J.142 E.0464
G3 X116.475 Y128.667 I-1.496 J-.169 E.61296
G3 X117.897 Y126.514 I1.334 J-.665 E.49792
G3 X118.747 Y126.848 I-.11 J1.527 E.14819
; WIPE_START
G1 F3215.099
M204 S6000
G1 X118.977 Y127.078 E-.12346
G1 X119.115 Y127.287 E-.09491
G1 X119.213 Y127.509 E-.09248
G1 X119.307 Y127.859 E-.13755
G1 X119.279 Y128 E-.05486
G1 X119.307 Y128.142 E-.05486
G1 X119.283 Y128.273 E-.05056
G1 X119.166 Y128.61 E-.1357
G1 X119.146 Y128.646 E-.01563
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z28.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z28.8
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
            G0 Z28.8 F4000
            G39.3 S1
            G0 Z28.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


G1 X118.997 Y128.018 F42000
G1 Z28.4
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.948727
G1 F1200
M204 S2000
G1 X118.172 Y127.194 E.2205
G2 X117.177 Y127.37 I-.37 J.807 E.20326
G1 X118.436 Y128.63 E.33669
G3 X117.452 Y128.817 I-.638 J-.671 E.20014
G1 X116.602 Y127.967 E.22724
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F2715.587
M204 S6000
G1 X117.452 Y128.817 E-.45677
G1 X117.559 Y128.856 E-.04312
G1 X117.797 Y128.892 E-.09143
G1 X117.93 Y128.883 E-.0506
G1 X118.161 Y128.819 E-.09112
G1 X118.223 Y128.786 E-.02696
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z28.8 I1.217 J0 P1  F42000
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
G1 Z28.8 F900 ; lower z a little
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

    G1 Z128.4 F600
    G1 Z126.4

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

