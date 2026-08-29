require "./spec_helper"

# The whole point of the answer key is that it never silently drifts from the
# catalog again. These assertions run both directions of parity — every live
# maze has a solution, every solution names a live maze — and list the offending
# names so a failure says exactly what to fix.
describe "solutions answer key" do
  live_names = Xssmaze.get.map(&.name).to_set
  entries = Xssmaze::Solutions.entries
  entry_names = entries.keys.to_set

  it "has a solution entry for every maze in the catalog" do
    missing = (live_names - entry_names).to_a.sort!
    unless missing.empty?
      fail "#{missing.size} maze(s) have no solution entry:\n  #{missing.join("\n  ")}"
    end
  end

  it "has no solution entry naming a maze that no longer exists" do
    orphans = (entry_names - live_names).to_a.sort!
    unless orphans.empty?
      fail "#{orphans.size} solution entry/entries name a maze that no longer exists:\n  #{orphans.join("\n  ")}"
    end
  end

  it "records a payload and context for every entry" do
    incomplete = entries.reject { |_, sol| !sol.payload.strip.empty? && !sol.context.strip.empty? }
      .keys.sort!
    unless incomplete.empty?
      fail "#{incomplete.size} entry/entries missing a payload or context:\n  #{incomplete.join("\n  ")}"
    end
  end

  it "exposes a markdown page per category, keyed by file stem" do
    Xssmaze::Solutions.categories.each do |category|
      Xssmaze::Solutions.markdown(category).should_not be_nil
    end
    Xssmaze::Solutions.markdown("does-not-exist").should be_nil
  end

  it "serves the answer key as JSON keyed by maze name" do
    parsed = JSON.parse(Xssmaze::Solutions.json_body).as_h
    parsed.size.should eq(entries.size)
    sample = parsed["basic-level1"].as_h
    sample["payload"].as_s.should_not be_empty
    sample["context"].as_s.should_not be_empty
    sample["url"].as_s.should_not be_empty
  end

  # A maze marked `exploitable: false` in the catalog is a deliberate true
  # negative — a scanner that reports nothing there is *correct*. Its answer-key
  # entry must read as a control, not a live exploit, or `/solutions.json` and
  # `/map/json` contradict each other and a scanner author is told a control is
  # exploitable. That is precisely the drift the earlier parity checks cannot
  # catch: they assert an entry *exists*, never that it is *true*.
  #
  # The cheap, unfakeable marker is the payload field. A control has no working
  # payload, so its `- payload:` states as much and carries the word "control";
  # the parser keeps only the code-span text, so the marker has to live inside
  # the span (`\`no payload — control\``), not trail it. We match the substring
  # rather than an exact string to leave the wording free, and no real exploit
  # payload (`<script>…`, `javascript:…`, `" onerror=…`) carries it by accident.
  control_marker = "control"

  it "documents every `exploitable: false` maze as a control, not an exploit" do
    offenders = Xssmaze.get.reject(&.exploitable?).compact_map do |maze|
      sol = entries[maze.name]?
      next if sol.nil? # a missing entry is the parity check's job, not this one
      "#{maze.name}  (payload: #{sol.payload.inspect})" \
        unless sol.payload.downcase.includes?(control_marker)
    end.sort!

    unless offenders.empty?
      fail <<-MSG
        #{offenders.size} control(s) have a solution payload that reads as a live exploit:
          #{offenders.join("\n  ")}

        A maze with `exploitable: false` is a true negative — there is no working
        payload. Its `- payload:` line must say so: the standard marker is
        `no payload — control` (inside the code span), with the reasoning — and any
        different-bug-class detail, e.g. the open redirect or the XS-Leak oracle —
        moved into `- context:`.
        MSG
    end
  end
end
