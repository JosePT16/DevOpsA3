pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  environment {
    REPORTS_DIR = "reports"
    PYTHONPATH  = "."
    VENV_DIR    = ".venv-ci"
    SQLITE_DB_PATH = "ci.db"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Environment setup') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          python --version

          python -m venv "$env:VENV_DIR"

          & "$env:VENV_DIR\\Scripts\\python.exe" -m pip install --upgrade pip
          & "$env:VENV_DIR\\Scripts\\pip.exe" install -r requirements.txt -r requirements-dev.txt

          if (!(Test-Path $env:REPORTS_DIR)) { New-Item -ItemType Directory -Path $env:REPORTS_DIR | Out-Null }
        '''
      }
    }

    stage('Code quality - format (Black)') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          & "$env:VENV_DIR\\Scripts\\black.exe" --check .
        '''
      }
      post {
        failure {
          echo "Black formatting check failed. Fix locally by running: black ."
        }
      }
    }

    stage('Code quality - lint (flake8)') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          & "$env:VENV_DIR\\Scripts\\flake8.exe"
        '''
      }
      post {
        failure {
          echo "flake8 failed. Fix locally by running: flake8"
        }
      }
    }

    stage('Tests + Coverage') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"

          & "$env:VENV_DIR\\Scripts\\python.exe" -m pytest `
            --junitxml="$env:REPORTS_DIR\\junit.xml" `
            --cov=app `
            --cov-report=term-missing `
            --cov-report=xml:"$env:REPORTS_DIR\\coverage.xml" `
            --cov-report=html:"$env:REPORTS_DIR\\htmlcov" `
            --cov-fail-under=80
        '''
      }
      post {
        always {
          junit allowEmptyResults: false, testResults: 'reports/junit.xml'
          archiveArtifacts artifacts: 'reports/**', fingerprint: true
        }
        failure {
          echo "Tests or coverage failed. Run locally: python -m pytest --cov=app --cov-fail-under=80"
        }
      }
    }

    stage('Build') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          & "$env:VENV_DIR\\Scripts\\python.exe" -m build

          if (Test-Path "dist") {
            Get-ChildItem dist | Format-Table
          }
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'dist/**', fingerprint: true
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline finished for branch: ${env.BRANCH_NAME}"
    }
  }
}
