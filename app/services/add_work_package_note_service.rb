#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

##
# Create journal for the given user and note.
# Does not change the work package itself.

class AddWorkPackageNoteService
  include Contracted
  attr_accessor :user, :work_package

  def initialize(user:, work_package:)
    self.user = user
    self.work_package = work_package
    self.contract_class = WorkPackages::CreateNoteContract
  end

  def call(notes, is_public: true, send_notifications: true)
    Journal::NotificationConfiguration.with send_notifications do
      work_package.add_journal(user, notes, is_public)
      
      success, errors = validate_and_yield(work_package, user) do
        work_package.save_journals
      end

      if errors.present? && errors.any? { |e| e.attribute.to_s.include?('custom_field') }
        work_package.save

        success, errors = validate_and_yield(work_package, user) do
          work_package.save_journals
        end
      end
      journal = work_package.journals.last if success
      ServiceResult.new(success:, result: journal, errors:)
    end
  end
end
