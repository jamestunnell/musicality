### 0.6.0 / 2015-04-28
* Add Score DSL
* Add composition convenience methods `e`, `q`, and `dq` for generating eighth, quarter, and dotted quarter notes
* Add part selection and titling to Lilypond score engraver

### 0.5.0 / 2015-04-27
* Alter note syntax
 * shift articulation placement to after pitches
 * disallow articulation and accent when pitches aren't present
 * do not provide syntax for targeted slur and legato links
* Add *basic* support for Lilypond engraving (sheet music printing)
* Add `#to_midi_seq` convenience method to `Timed` and `TempoBased` scores.
* Add some rudimentary composition features
 * `ScaleClass` class: contains a series of increasing pitch intervals. Can be realized as a scale given a starting pitch class.
 * `Scale` class: contains a starting pitch class, and a series of pitch intervals. Can be realized as a series of pitches given a starting octave.
 * Biinfinite sequence generators for adding and repeating
 * Random rhythm generator
 * Counterpoint generator
* Instead of `Program` class, use plain array for Score program
* Add (optional) argument to Score::Measured#measures_long, to convert a specific note duration to measure duration. If not specified, the note duration of the longest part is used (as before).

### 0.3.0 / 2014-12-01
* Conversion of both tempo-based scores (measured and unmeasured) directly to time-based score
* Trimming of gradual changes, useful in collating scores
* Refactoring of ValueComputer using Function and Transition utility classes
* Add optional start_value for gradual changes, for making them absolute (by default they're relative) 
* Add 'with' kw arg to change pack/unpack methods, for converting start/end values

### 0.2.0 / 2014-11-24

* Add #seconds_long for timed score, #notes_long for tempo-based scores, and #measures_long for measure-based score

### 0.1.0 / 2014-11-23

* Pitch class that includes octave, semitone, and cent values
* Note class that includes duration, pitches, articulation, accent, and links
* Part class that includes notes and dynamics
* Program class to define which sections are played, and in what order
* Score classes, all of which include parts and a program, but more specifically:
 * Measured score that also includes tempo and meter changes. It has measure-based program and changes, and note-based notes
 * Unmeasured score that also includes tempo changes. It has note-based program, changes, notes
 * Timed score which is entirely time-based
* Pass block to help initialize a score or a part
* Validation of core model classes (score, part, program, note, etc.), with error list
* Based on Ruby 2.0
* Stringizing and parsing methods for duration, pitch, note, and meter
* Stringized notes include shorthand for note links and articulation
* Packing/unpacking to/from hash, using stringizing/parsing to condense, esp. for notes
* Convert score to MIDI file via midilib gem
* bin/midify command-line utility to run MIDI conversion on score YAML file

