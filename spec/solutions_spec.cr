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
end
