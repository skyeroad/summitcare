# summitcare-api

The Rails 8 API for SummitCare, the fictional patient portal in *A Primer on
HIPAA for Healthcare Systems Developers*. Synthetic data only; a teaching
example, not production-ready. See the top-level `README.md` for setup, tests,
and the map from each Solution to its files.

    bin/setup --skip-server   # roles, databases, migrations
    bin/rails test            # whole suite
    bin/rails test test/controls
