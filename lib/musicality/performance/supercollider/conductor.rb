module Musicality
module SuperCollider

class Conductor
  def initialize score
    unless score.is_a?(Score::Timed)
      raise ArgumentError, "The given score is not a Score::Timed. \
      Convert it first using ScoreConverter."
    end

    parts = score.collated? ? score.parts : ScoreCollator.new(score).collate_parts
    @performers = Hash[ parts.map do |name, part|
      [name, Performer.new(part)]
    end]
  end

  def perform base_fpath, selected_parts: @performers.keys, verbose: false, lead_time: 0.1
    bundles = bundles(selected_parts, lead_time)
    fpath = write_sc_code bundles, base_fpath
    exec_sc_code fpath, bundles.last.time, verbose
    File.delete(fpath)
  end

  def bundles selected_parts = @performers.keys, lead_time
    Node.reset_id_counter

    default_group = Group.default(nil)
    aux_audio_bus = 16
    volume_control_bus = 0
    bundle_kwargs = {
      :parent_group => default_group,
      :aux_audio_bus => aux_audio_bus,
      :volume_control_bus => volume_control_bus,
      :lead_time => lead_time
    }

    all_bundles = [ default_group.bundle_queue(0.0) ]
    selected_parts.each do |name|
      bundles = @performers[name].bundles(**bundle_kwargs)
      bundle_kwargs[:aux_audio_bus] += 2
      bundle_kwargs[:volume_control_bus] += 1
      all_bundles.concat bundles
    end
    all_bundles = all_bundles.sort_by {|b| b.time }
    default_group.free_all
    all_bundles.push(default_group.bundle_queue(lead_time+all_bundles.last.time))

    coalesced_bundles = []
    all_bundles.each do |bundle|
      if coalesced_bundles.any? && coalesced_bundles.last.time == bundle.time
        coalesced_bundles.last.messages.concat bundle.messages
      else
        coalesced_bundles.push bundle
      end
    end

    return coalesced_bundles
  end

  private

  BASE_FPATH_PLACEHOLDER = "BASE_FPATH"
  SYNTHDEFS_PLACEHOLDER = "SYNTHDEFS"
  COMPLETION_MSG = "Work complete."
  POST_PID_MSG = "sclang pid:"

  SC_HEADER = <<SCLANG
// auto-generated by Musicality

(\"#{POST_PID_MSG}\" + thisProcess.pid).postln;

#{SYNTHDEFS_PLACEHOLDER}

(
  x = [
SCLANG

  SC_FOOTER = <<SCLANG
  ];

  f = File(\"#{BASE_FPATH_PLACEHOLDER}.osc\","w");
  x.do({ arg item, i;
    var bytes = item.asRawOSC;
    f.write(bytes.size);
    f.write(bytes);
  });
  f.close;

  \"#{COMPLETION_MSG}\".postln;
);
SCLANG

  def write_sc_code bundles, base_fpath
    fpath = "#{base_fpath}.scd"
    File.open(fpath, "w") do |f|
      synthdefs = [ SynthDefs::VOLUME_CONTROL, SynthDefs::VOLUME_CHANGE ] + @performers.values.map {|p| p.settings.synthdef }

      f.write SC_HEADER.gsub(SYNTHDEFS_PLACEHOLDER, synthdefs.map {|s| s.to_sclang }.join("\n\n"))
      f.write bundles.map {|b| "    " + b.to_sclang }.join(",\n") + "\n"
      f.write SC_FOOTER.gsub(BASE_FPATH_PLACEHOLDER, base_fpath)
    end
    fpath
  end

  def exec_sc_code fpath, last_time, verbose
    post_sclang_pid = Regexp.new(POST_PID_MSG + " ([0-9]+)")

    sclang_pid = nil
    IO.popen("sclang \"#{fpath}\"") do |io|
      pid = io.pid      
      while response = io.gets
        puts response if verbose

        case response.chomp
        when post_sclang_pid
          sclang_pid = $1.to_i
        when COMPLETION_MSG
          if OS.windows?
            Process.kill 9, sclang_pid
          else
            Process.kill "INT", sclang_pid
          end
        end
      end
    end
  end
end

end
end