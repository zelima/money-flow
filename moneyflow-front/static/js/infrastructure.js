// Infrastructure Flow Diagram JavaScript
// Handles the interactive developer experience flow visualization

document.addEventListener('DOMContentLoaded', function() {
    initializeFlowDiagram();
});

function initializeFlowDiagram() {
    const flowSteps = document.querySelectorAll('.flow-step');
    const connectionLines = document.querySelectorAll('.connection-line');

    // Add click event listeners to flow steps
    flowSteps.forEach(step => {
        step.addEventListener('click', function() {
            highlightStep(this);
            showStepDetails(this);
        });

        // Add hover effects
        step.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.05)';
        });

        step.addEventListener('mouseleave', function() {
            if (!this.classList.contains('active')) {
                this.style.transform = 'scale(1)';
            }
        });
    });

    // Add hover effects to connection lines
    connectionLines.forEach(line => {
        line.addEventListener('mouseenter', function() {
            highlightConnection(this);
        });

        line.addEventListener('mouseleave', function() {
            resetConnectionHighlight(this);
        });
    });

    // Initialize with first step highlighted
    if (flowSteps.length > 0) {
        highlightStep(flowSteps[0]);
    }
}

function highlightStep(step) {
    // Remove active class from all steps
    document.querySelectorAll('.flow-step').forEach(s => {
        s.classList.remove('active');
        s.style.transform = 'scale(1)';
    });

    // Add active class to clicked step
    step.classList.add('active');
    step.style.transform = 'scale(1.1)';

    // Add visual feedback
    step.style.boxShadow = '0 12px 35px rgba(69, 176, 137, 0.4)';

    // Highlight related connections
    highlightRelatedConnections(step);
}

function highlightRelatedConnections(step) {
    const serviceType = step.dataset.service;
    const stepNumber = step.dataset.step;

    // Reset all connection highlights
    document.querySelectorAll('.connection-line').forEach(line => {
        line.style.opacity = '0.5';
        line.style.transform = 'scale(1)';
    });

    // Highlight connections related to this step
    if (serviceType) {
        document.querySelectorAll(`[data-from="${serviceType}"], [data-to="${serviceType}"]`).forEach(line => {
            line.style.opacity = '1';
            line.style.transform = 'scale(1.1)';
            line.style.background = 'rgba(69, 176, 137, 0.2)';
        });
    }
}

function highlightConnection(line) {
    line.style.background = 'rgba(69, 176, 137, 0.3)';
    line.style.transform = 'scale(1.1)';
}

function resetConnectionHighlight(line) {
    line.style.background = 'rgba(69, 176, 137, 0.1)';
    line.style.transform = 'scale(1)';
}

function showStepDetails(step) {
    const stepNumber = step.dataset.step;
    const stepTitle = step.querySelector('h4').textContent;

    // Create or update tooltip with step details
    let tooltip = document.getElementById('step-tooltip');
    if (!tooltip) {
        tooltip = document.createElement('div');
        tooltip.id = 'step-tooltip';
        tooltip.className = 'step-tooltip';
        document.body.appendChild(tooltip);
    }

    // Set tooltip content based on step
    const stepDetails = getStepDetails(stepNumber, stepTitle);
    tooltip.innerHTML = stepDetails;

    // Position tooltip near the step
    const rect = step.getBoundingClientRect();
    tooltip.style.left = rect.left + 'px';
    tooltip.style.top = (rect.bottom + 10) + 'px';
    tooltip.style.display = 'block';

    // Hide tooltip after 3 seconds
    setTimeout(() => {
        tooltip.style.display = 'none';
    }, 3000);
}

function getStepDetails(stepNumber, stepTitle) {
    const details = {
        '1': {
            title: 'make start',
            description: 'Developer runs the make start command to begin local development',
            command: 'make start',
            details: 'This command triggers the entire development environment setup'
        },
        '2': {
            title: 'Docker Compose',
            description: 'Docker Compose orchestrates all the services',
            command: 'docker-compose up -d',
            details: 'Starts PostgreSQL, FastAPI backend, and Flask frontend services'
        },
        '3': {
            title: 'Services',
            description: 'Three main services are started and connected',
            command: 'Services running on ports 5432, 8000, 5000',
            details: 'PostgreSQL database, FastAPI backend API, Flask web interface'
        },
        '4': {
            title: 'Fixtures',
            description: 'Database is populated with initial data and schema',
            command: 'SQL scripts in fixtures/init/',
            details: 'Creates tables, seed data, and historical budget records'
        },
        '5': {
            title: 'Developer Access',
            description: 'Application is accessible at localhost:5000',
            command: 'http://localhost:5000',
            details: 'Developer can now interact with the full application'
        }
    };

    const step = details[stepNumber] || {};

    return `
        <div class="tooltip-header">
            <h4>${step.title || stepTitle}</h4>
        </div>
        <div class="tooltip-content">
            <p><strong>Description:</strong> ${step.description || 'Step details'}</p>
            <p><strong>Command:</strong> <code>${step.command || 'N/A'}</code></p>
            <p><strong>Details:</strong> ${step.details || 'Additional information'}</p>
        </div>
    `;
}

// Add CSS for tooltip
function addTooltipStyles() {
    if (!document.getElementById('tooltip-styles')) {
        const style = document.createElement('style');
        style.id = 'tooltip-styles';
        style.textContent = `
            .step-tooltip {
                position: absolute;
                background: white;
                border: 2px solid #45b089;
                border-radius: 8px;
                padding: 15px;
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
                z-index: 1000;
                max-width: 300px;
                display: none;
                animation: fadeIn 0.3s ease-in;
            }

            .tooltip-header h4 {
                margin: 0 0 10px 0;
                color: #45b089;
                font-size: 1.1rem;
            }

            .tooltip-content p {
                margin: 5px 0;
                font-size: 0.9rem;
                line-height: 1.4;
            }

            .tooltip-content code {
                background: #f0f0f0;
                padding: 2px 6px;
                border-radius: 4px;
                font-family: monospace;
                font-size: 0.8rem;
            }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(-10px); }
                to { opacity: 1; transform: translateY(0); }
            }
        `;
        document.head.appendChild(style);
    }
}

// Initialize tooltip styles
addTooltipStyles();
