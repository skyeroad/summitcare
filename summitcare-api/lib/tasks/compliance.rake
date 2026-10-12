namespace :compliance do
  desc "Build a dated evidence pack in tmp/evidence/YYYY-MM-DD"
  task evidence: :environment do
    pack = Rails.root.join("tmp/evidence", Date.current.iso8601)
    FileUtils.mkdir_p(pack)
    run = ->(file, *cmd) { system(*cmd, out: pack.join(file).to_s, err: [:child, :out]) }

    results = {
      control_tests: run.("control-tests.txt", { "RAILS_ENV" => "test" }, "bin/rails", "test", "test/controls"),
      brakeman: run.("brakeman.txt", "bin/brakeman", "--no-pager", "-o", pack.join("brakeman.json").to_s),
      dependency_audit: run.("bundler-audit.txt", "bundle", "exec", "bundler-audit", "check", "--update"),
      iam_snapshot: run.("iam-summitcare-app.json", "aws", "iam", "get-role-policy",
                         "--role-name", "summitcare-app", "--policy-name", "summitcare-app-access")
    }
    File.write(pack.join("encryption-inventory.json"), JSON.pretty_generate(EvidencePack.encryption_inventory))
    File.write(pack.join("manifest.json"), JSON.pretty_generate({
      generated_at: Time.current.utc.iso8601, git_sha: `git rev-parse HEAD`.strip, results: results
    }))
    puts "Evidence pack written to #{pack}"
  end

  desc "Print the last successful restore drill and audit chain verification"
  task operational_status: :environment do
    puts JSON.pretty_generate(EvidencePack.operational_status)
  end
end
