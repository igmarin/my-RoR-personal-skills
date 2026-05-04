# Extract ReportingModule Into a Rails Engine

## Problem/Feature Description

The `ReportingModule` in the `BizApp` host application has grown into a self-contained feature: its own models, mailers, controllers, and views. The team wants to extract it into a standalone `Reporting` Rails engine that can be mounted in other apps.

The relevant host-app files are provided below. Extract them before beginning.

=============== FILE: app/models/report.rb ===============
# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  scope :recent, -> { order(created_at: :desc).limit(10) }

  def self.generate_for(user)
    # ... complex report generation logic
    create!(user: user, data: {}, generated_at: Time.current)
  end
end
=============== END FILE ===============

=============== FILE: app/controllers/reports_controller.rb ===============
# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reports = current_user.reports.recent
  end

  def show
    @report = current_user.reports.find(params[:id])
  end

  def create
    result = Report.generate_for(current_user)
    if result.persisted?
      redirect_to report_path(result), notice: 'Report generated.'
    else
      redirect_to reports_path, alert: 'Could not generate report.'
    end
  end
end
=============== END FILE ===============

=============== FILE: app/mailers/report_mailer.rb ===============
# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def report_ready(report)
    @report = report
    mail(to: report.user.email, subject: "Your report is ready")
  end
end
=============== END FILE ===============

## Output Specification

Produce the following file tree (scaffold only — no full implementation required):

```
engines/reporting/
├── lib/
│   ├── reporting.rb
│   └── reporting/
│       ├── engine.rb
│       └── version.rb
├── app/
│   ├── models/reporting/report.rb
│   ├── controllers/reporting/reports_controller.rb
│   └── mailers/reporting/report_mailer.rb
└── reporting.gemspec
```

Each file should:
- Be properly namespaced under `Reporting::`
- Have `isolate_namespace Reporting` in the engine
- Have frozen_string_literal headers
- Include a minimal YARD class-level comment
