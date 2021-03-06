# basic core classes
require 'musicality/version'
require 'musicality/packable'
require 'musicality/validatable'
require 'musicality/errors'

require 'musicality/pitch_class'
require 'musicality/pitch_classes'

#
# Notation
#

require 'musicality/notation/model/pitch'
require 'musicality/notation/model/pitches'
require 'musicality/notation/model/articulations'
require 'musicality/notation/model/link'
require 'musicality/notation/model/mark'
require 'musicality/notation/model/marks'
require 'musicality/notation/model/symbols'
require 'musicality/notation/model/note'
require 'musicality/notation/model/dynamics'
require 'musicality/notation/model/change'
require 'musicality/notation/model/part'
require 'musicality/notation/model/meter'
require 'musicality/notation/model/meters'
require 'musicality/notation/model/key'
require 'musicality/notation/model/keys'
require 'musicality/notation/model/audition'
require 'musicality/notation/model/score'

require 'treetop'
require 'musicality/notation/parsing/numbers/nonnegative_integer_parsing'
require 'musicality/notation/parsing/numbers/positive_integer_parsing'
require 'musicality/notation/parsing/numbers/positive_float_parsing'
require 'musicality/notation/parsing/numbers/positive_rational_parsing'
require 'musicality/notation/parsing/numbers/nonnegative_float_parsing'
require 'musicality/notation/parsing/numbers/nonnegative_rational_parsing'
require 'musicality/notation/parsing/pitch_parsing'
require 'musicality/notation/parsing/pitch_node'
require 'musicality/notation/parsing/key_parsing'
require 'musicality/notation/parsing/duration_parsing'
require 'musicality/notation/parsing/duration_nodes'
require 'musicality/notation/parsing/articulation_parsing'
require 'musicality/notation/parsing/link_parsing'
require 'musicality/notation/parsing/link_nodes'
require 'musicality/notation/parsing/mark_parsing'
require 'musicality/notation/parsing/note_parsing'
require 'musicality/notation/parsing/note_node'
require 'musicality/notation/parsing/meter_parsing'
require 'musicality/notation/parsing/segment_parsing'
require 'musicality/notation/parsing/parseable'
require 'musicality/notation/parsing/convenience_methods'

require 'musicality/notation/util/interpolation'
require 'musicality/notation/util/function'
require 'musicality/notation/util/piecewise_function'
require 'musicality/notation/util/transition'
require 'musicality/notation/util/value_computer'

require 'musicality/notation/conversion/tempo_conversion'
require 'musicality/notation/conversion/change_conversion'
require 'musicality/notation/conversion/note_time_converter'
require 'musicality/notation/conversion/score_converter'
require 'musicality/notation/conversion/score_conversion'

#
# Composition
#

require 'musicality/composition/util/biinfinite_sequence'
require 'musicality/composition/util/repeating_sequence'
require 'musicality/composition/util/adding_sequence'
require 'musicality/composition/util/compound_sequence'
require 'musicality/composition/util/random_sampler'
require 'musicality/composition/util/probabilities'
require 'musicality/composition/util/note_generation'

require 'musicality/composition/model/intervals'
require 'musicality/composition/model/chord_class'
require 'musicality/composition/model/chord_classes'
require 'musicality/composition/model/scale'
require 'musicality/composition/model/scale_class'
require 'musicality/composition/model/scale_classes'
require 'musicality/composition/model/rhythm_class'
require 'musicality/composition/model/rhythm'

require 'musicality/composition/sequencing/sequenceable'
require 'musicality/composition/sequencing/note_fifo'
require 'musicality/composition/sequencing/sequencer'
require 'musicality/composition/sequencing/note_array'
require 'musicality/composition/sequencing/drum_machine/drum_parts'
require 'musicality/composition/sequencing/drum_machine/drum_pattern'
require 'musicality/composition/sequencing/drum_machine/drum_patterns/pop_drum_patterns'
require 'musicality/composition/sequencing/drum_machine/drum_kit'
require 'musicality/composition/sequencing/drum_machine/drum_machine'

require 'musicality/composition/generation/counterpoint_generator'
require 'musicality/composition/generation/random_rhythm_generator'

require 'musicality/composition/dsl/score_methods'
require 'musicality/composition/dsl/part_methods'
require 'musicality/composition/dsl/score_dsl'

require 'musicality/composition/convenience_methods'

#
# Performance
#

require 'musicality/performance/model/attack'
require 'musicality/performance/model/separation'
require 'musicality/performance/model/duration_functions'
require 'musicality/performance/model/note_sequence'

require 'musicality/performance/util/optimization'

require 'musicality/performance/conversion/glissando_converter'
require 'musicality/performance/conversion/portamento_converter'
require 'musicality/performance/conversion/note_sequence_extractor'
require 'musicality/performance/conversion/score_collator'

require 'midilib'
require 'musicality/performance/midi/midi_util'
require 'musicality/performance/midi/midi_events'
require 'musicality/performance/midi/midi_settings'
require 'musicality/performance/midi/part_sequencer'
require 'musicality/performance/midi/score_sequencer'
require 'musicality/performance/midi/score_sequencing'

require 'os'
require 'musicality/performance/supercollider/message'
require 'musicality/performance/supercollider/bundle'
require 'musicality/performance/supercollider/server'
require 'musicality/performance/supercollider/add_actions'
require 'musicality/performance/supercollider/node'
require 'musicality/performance/supercollider/synth'
require 'musicality/performance/supercollider/group'
require 'musicality/performance/supercollider/synthdef'
require 'musicality/performance/supercollider/synthdefs/bass'
require 'musicality/performance/supercollider/synthdefs/claps'
require 'musicality/performance/supercollider/synthdefs/cymbals'
require 'musicality/performance/supercollider/synthdefs/hihats'
require 'musicality/performance/supercollider/synthdefs/kicks'
require 'musicality/performance/supercollider/synthdefs/mario'
require 'musicality/performance/supercollider/synthdefs/other'
require 'musicality/performance/supercollider/synthdefs/pianos'
require 'musicality/performance/supercollider/synthdefs/snares'
require 'musicality/performance/supercollider/synthdefs/toms'
require 'musicality/performance/supercollider/synthdefs/volume'
require 'musicality/performance/supercollider/performer'
require 'musicality/performance/supercollider/conductor'
require 'musicality/performance/supercollider/score_conducting'
require 'musicality/performance/supercollider/sc_drum_kits'

#
# Printing
#

require 'musicality/printing/lilypond/errors'
require 'musicality/printing/lilypond/pitch_class_engraving'
require 'musicality/printing/lilypond/pitch_engraving'
require 'musicality/printing/lilypond/note_engraving'
require 'musicality/printing/lilypond/meter_engraving'
require 'musicality/printing/lilypond/key_engraving'
require 'musicality/printing/lilypond/clef'
require 'musicality/printing/lilypond/lilypond_settings'
require 'musicality/printing/lilypond/part_engraver'
require 'musicality/printing/lilypond/score_engraver'
require 'musicality/printing/lilypond/score_engraving'

#
# Project
#

require 'rake'
require 'yaml'
require 'rake/tasklib'
require 'musicality/project/project'
require 'musicality/project/file_raker'
require 'musicality/project/file_cleaner'
require 'musicality/project/auditions_task'
require 'musicality/project/create_tasks'
