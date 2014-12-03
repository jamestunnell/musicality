# basic core classes
require 'musicality/version'
require 'musicality/validatable'
require 'musicality/errors'

#
# Notation
#

require 'musicality/notation/model/pitch'
require 'musicality/notation/model/pitches'
require 'musicality/notation/model/link'
require 'musicality/notation/model/articulations'
require 'musicality/notation/model/note'
require 'musicality/notation/model/dynamics'
require 'musicality/notation/model/change'
require 'musicality/notation/model/part'
require 'musicality/notation/model/program'
require 'musicality/notation/model/meter'
require 'musicality/notation/model/meters'
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
require 'musicality/notation/parsing/duration_parsing'
require 'musicality/notation/parsing/duration_nodes'
require 'musicality/notation/parsing/articulation_parsing'
require 'musicality/notation/parsing/link_parsing'
require 'musicality/notation/parsing/link_nodes'
require 'musicality/notation/parsing/note_parsing'
require 'musicality/notation/parsing/note_node'
require 'musicality/notation/parsing/meter_parsing'
require 'musicality/notation/parsing/segment_parsing'
require 'musicality/notation/parsing/parseable'
require 'musicality/notation/parsing/convenience_methods'

require 'musicality/notation/packing/change_packing'
require 'musicality/notation/packing/part_packing'
require 'musicality/notation/packing/program_packing'
require 'musicality/notation/packing/score_packing'

require 'musicality/notation/util/interpolation'
require 'musicality/notation/util/function'
require 'musicality/notation/util/piecewise_function'
require 'musicality/notation/util/transition'
require 'musicality/notation/util/value_computer'

require 'musicality/notation/conversion/tempo_conversion'
require 'musicality/notation/conversion/change_conversion'
require 'musicality/notation/conversion/note_time_converter'
require 'musicality/notation/conversion/measure_note_map'
require 'musicality/notation/conversion/score_converter'
require 'musicality/notation/conversion/score_conversion'

#
# Composition
#

require 'musicality/composition/model/pitch_class'
require 'musicality/composition/model/pitch_classes'
require 'musicality/composition/model/interval_array'

require 'musicality/composition/note_generation'
require 'musicality/composition/transposition'

#
# Performance
#

require 'musicality/performance/model/note_attacks'
require 'musicality/performance/model/note_sequence'

require 'musicality/performance/util/optimization'
require 'musicality/performance/util/note_linker'

require 'musicality/performance/conversion/glissando_converter'
require 'musicality/performance/conversion/portamento_converter'
require 'musicality/performance/conversion/note_sequence_extractor'
require 'musicality/performance/conversion/score_collator'

require 'midilib'
require 'musicality/performance/midi/midi_util'
require 'musicality/performance/midi/midi_events'
require 'musicality/performance/midi/part_sequencer'
require 'musicality/performance/midi/score_sequencer'
