<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assessment Form</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <style>
        #loading {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5); /* Semi-transparent black background */
            z-index: 9999;
        }

        .spinner {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            border: 5px solid #f3f3f3; /* Light grey */
            border-top: 5px solid #3498db; /* Blue */
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite; /* Spin animation */
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .custom-modal-header {
                background-color: #4895d9; /* Dark background color */
                color: white; /* Text color */
                border-bottom: 1px solid #dee2e6; /* Light border for separation */
            }

            .custom-modal-header .modal-title {
                font-weight: 600; /* Bold title */
            }

            .custom-close {
                color: white; /* White close button */
                opacity: 0.8; /* Slightly transparent */
            }

            .custom-close:hover {
                color: red; /* Slightly lighter color on hover */
                opacity: 1; /* Full opacity on hover */
            }

            /* Optional: Add some margin to the body of the modal */
            .modal-body {
                margin-bottom: 20px; /* Add margin for spacing */
        }
    </style>
</head>
    <%@ include file="navbar.jsp" %>
    <%@ include file="common-imports.jsp" %>


    <c:set var="username" value="${pageContext.request.userPrincipal.name}" />

    <c:choose>
    <c:when test="${username == 'admin'}">
        <c:set var="formAction" value="${pageContext.request.contextPath}/admin/addAssessment?batchId=${batchId}" />
    </c:when>
    <c:otherwise>
        <c:set var="formAction" value="${pageContext.request.contextPath}/trainer/?batchId=${batchId}" />
    </c:otherwise>
    </c:choose>


       <div class="container mt-4">
           <div class="row justify-content-center">
               <div class="col-md-8">
                   <div class="card shadow">
                       <form:form method="POST" modelAttribute="assessmentDto" id="assessmentForm" action="${formAction}">
                           <div class="card-body" id="innerContainer">
                               <div class="d-flex justify-content-between align-items-center mb-4">
                                   <h2 class="mb-0">Add new Assessment</h2>
                                   <div>
                                       <button type="submit" class="btn btn-primary mr-2">Save</button>
                                       <button type="button" class="btn btn-secondary" id="cancelButton">Cancel</button>
                                   </div>
                               </div>
                               <div class="form-group">
                                   <label for="subTopic">Enter Assessment Topic <span class="text-danger">*</span>:</label>
                                   <form:input type="text" class="form-control" id="subTopic" path="subTopic" placeholder="Assessment Topic: ModuleName Assessment-AssessmentCount" required="true" />
                               </div>
                               <div class="form-group">
                                   <label for="plannedDate">Enter Planned Date<span class="text-danger">*</span>:</label>
                                   <form:input type="date" class="form-control" id="plannedDate" path="plannedDate" placeholder="Enter Planned Date" required="true" />
                               </div>
                               <div class="form-group">
                                   <label for="totalScore">Enter total marks<span class="text-danger">*</span>:</label>
                                   <form:input type="number" class="form-control" id="totalScore" path="totalScore" placeholder="Enter total marks" required="true" min="1"/>
                               </div>

                               <!-- Hidden field for batch start date -->
                               <input type="hidden" id="batchStartDate" value="${batchStartDate}" />
                           </div>
                       </form:form>
                   </div>
               </div>
           </div>
       </div>


    <!-- Modal for error messages -->
    <div class="modal fade" id="errorModal" tabindex="-1" role="dialog" aria-labelledby="errorModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header custom-modal-header">
                    <h5 class="modal-title" id="errorModalLabel">Validation Error</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="errorMessage">
                    <!-- Error message will be injected here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal" style="background-color: #2382d7; color: black; font-weight:bold;">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Spinner for form submission -->
    <div id="loading">
        <div class="spinner"></div>
    </div>

    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var plannedDateInput = document.getElementById('plannedDate');
            var batchStartDateInput = document.getElementById('batchStartDate');
            var topicInput = document.getElementById('subTopic');
            var errorMessage = document.getElementById('errorMessage');
            var descriptionError = document.getElementById('descriptionError');
            var totalScoreInput = document.getElementById('totalScore');
            var loading = document.getElementById('loading');
            var form = document.getElementById('assessmentForm');

            function validatePlannedDate() {
                var plannedDate = new Date(plannedDateInput.value);
                 var day = plannedDate.getDay();
                var batchStartDate = new Date(batchStartDateInput.value);
                 var currentDateObj = new Date();
                 currentDateObj.setHours(0,0,0,0);

                 plannedDate.setHours(0,0,0,0);
                 batchStartDate.setHours(0,0,0,0);


                // Check if the planned date is a Saturday or Sunday

                if (day === 0 || day === 6) {
                    errorMessage.textContent = 'Planned date should not be on a Saturday or Sunday.';
                    $('#errorModal').modal('show');
                    plannedDateInput.value = ''; // Clear the input value
                    return false;
                }

                if(plannedDate<currentDateObj)
                 {
                     errorMessage.innerHTML = 'Planned date cannot be less than current date.';
                      $('#errorModal').modal('show');
                      setTimeout(function() {
                         plannedDateInput.value='' ;// Actually submit the form
                      }, 1500);
                      return false;
                 }
                // Check if the planned date is before the batch start date
                else if (plannedDate < batchStartDate) {
                    errorMessage.textContent = 'Planned date should be greater than the batch start date ${batchStartDate}.';
                    $('#errorModal').modal('show');
                    setTimeout(function() {
                        plannedDateInput.value = ''; // Clear the input value
                    }, 2000);
                    return false;
                }

                return true;
            }

            function validateSessionDescription() {
                var description = topicInput.value;
                var regex = /^[a-zA-Z\s0-9-]+$/;  // Only allows letters, digits, hyphen and spaces
                if (!regex.test(description)) {
                   errorMessage.textContent = 'Topic should not contain special character except Hyphen';
                   $('#errorModal').modal('show');
                   setTimeout(function() {
                       sessionDescriptionInput.value = ''; // Clear the input value after delay
                   }, 2000);
                   return false;
                }
                return true;
            }

             function validateTotalScore() {
                var totalScore = parseInt(totalScoreInput.value, 10);

                // Check if the total score is less than or equal to 0
                if (isNaN(totalScore) || totalScore <= 0) {
                    errorMessage.textContent = 'Total score should be greater than 0.';
                    $('#errorModal').modal('show');
                    setTimeout(function() {
                        totalScoreInput.value = ''; // Clear the input value after delay
                    }, 2000);
                    return false;
                }

                return true;
            }

            function validateForm() {
                var dateValid = validatePlannedDate();
                var descriptionValid = validateSessionDescription();
                var scoreValid = validateTotalScore(); // Include score validation
                return dateValid && descriptionValid && scoreValid;
            }

            topicInput.addEventListener('input', validateSessionDescription);
            plannedDateInput.addEventListener('input', validatePlannedDate);
            totalScoreInput.addEventListener('input', validateTotalScore);

            form.addEventListener('submit', function(event) {
                   if (!validateForm()) {
                       event.preventDefault(); // Prevent form submission if validation fails
                   } else {
                       loading.style.display = 'block'; // Show the spinner
                   }
               });

               cancelButton.addEventListener('click', function() {
                   loading.style.display = 'block'; // Show the spinner
                   setTimeout(function() {
                       window.history.back(); // Navigate back after delay
                   }, 100); // 100 milliseconds delay to ensure spinner is visible
               });
        });
    </script>
</body>
</html>
