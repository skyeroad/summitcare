class Api::V1::BaseController < ApplicationController
  include ActiveStorage::SetCurrent # needed for URLs from the Disk service in tests (Solution 9)
  include ApiAuthentication          # Solutions 3, 5, 30
  include BreakGlassAccess           # Solution 6 (after ApiAuthentication, so Current.user is set)
  include AuditsPhiAccess            # Solution 13
end
