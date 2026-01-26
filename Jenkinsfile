pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    skipDefaultCheckout(true)
  }

  environment {
    
    REPORTS_DIR = "reports"
    PYTHONPATH = "."
    VENV_DIR = ".venv-ci"
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
        sh '''
          set -eux
          python --version
          python -m venv "${VENV_DIR}"
          . "${VENV_DIR}/bin/activate"
          python -m pip install --upgrade pip
          pip install -r requirements.txt -r requirements-dev.txt
          mkdir -p "${REPORTS_DIR}"
        '''
      }
    }

    stage('Code quality - format (Black)') {
      steps {
        sh '''
          set -eux
          . "${VENV_DIR}/bin/activate"
          black --check .
        '''
      }
      post {
        failure {
          echo "Black formatting check failed. Fix by running: black ."
        }
      }
    }

    stage('Code quality - lint (flake8)') {
      steps {
        sh '''
          set -eux
          . "${VENV_DIR}/bin/activate"
          flake8
        '''
      }
      post {
        failure {
          echo "flake8 failed. Fix issues locally by running: flake8"
        }
      }
    }

    stage('Tests + Coverage') {
      steps {
        sh '''
          set -eux
          . "${VENV_DIR}/bin/activate"
          python -m pytest \
            --junitxml="${REPORTS_DIR}/junit.xml" \
            --cov=app \
            --cov-report=term-missing \
            --cov-report=xml:"${REPORTS_DIR}/coverage.xml" \
            --cov-report=html:"${REPORTS_DIR}/htmlcov" \
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
        sh '''
          set -eux
          . "${VENV_DIR}/bin/activate"
          python -m build
          ls -la dist || true
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
