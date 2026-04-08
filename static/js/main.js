$(document).ready(function () {
    // Global Variables for Gallery State
    let projectImages = []; // Array of images for the active project
    let currentImgIndex = 0; // Current image being viewed (0, 1, 2...)
    const items = $('.gallery-item');

    // --- 1. LOADER SCREEN ---
    setTimeout(function () {
        $('#loader').fadeOut(800, function () {
            $('#main-content').removeClass('d-none').addClass('fade-in');

            // On Desktop: If we are already on the gallery view, select the first project
            if (window.innerWidth > 768 && !$('#gallery-view').hasClass('d-none')) {
                if (items.length > 0) selectProject(items.first());
            }
        });
    }, 3000);

    // --- 2. MAIN NAVIGATION (Art / Books / Design) ---
    $('#show-art, #show-books, #show-design').on('click', function (e) {
        e.preventDefault();
        $('#home-view').fadeOut(400, function () {
            $('#gallery-view').hide().removeClass('d-none').fadeIn(600);

            // Auto-select first project on desktop when entering gallery
            if (window.innerWidth > 768) {
                selectProject(items.first());
            }
        });
        $('.nav-item a').removeClass('fw-bold');
        $(this).addClass('fw-bold');
    });

    $('#go-home').on('click', function () {
        $('#gallery-view').fadeOut(400, function () {
            $('#home-view').fadeIn(600);
        });
        $('.nav-item a').removeClass('fw-bold');
    });

    // --- 3. GALLERY CORE LOGIC ---

    // Function to load a specific project
    function selectProject(element) {
        // Update Sidebar UI
        items.removeClass('active');
        element.addClass('active');

        // Extract Data from HTML Attributes
        const rawImages = element.data('images') || element.data('img') || "";
        projectImages = rawImages.split('|'); // Splits "img1.jpg|img2.jpg" into an array
        currentImgIndex = 0;

        // Update Text Content
        $('#text-title, #display-title-mobile').text(element.data('title'));
        $('#display-num').text(element.find('.g-num').text());
        $('#display-desc').text(element.data('desc'));

        // Update Metadata (Medium, Year, etc.)
        const meta = element.data('meta');
        $('.metadata').html(`<p class="mb-0">${meta}</p>`);

        // Reset view to show the first image
        showImage(0);
    }

    // Function to show a specific image index
    function showImage(index) {
        currentImgIndex = index;
        $('#main-gallery-img').attr('src', projectImages[currentImgIndex]).removeClass('d-none');
        $('#gallery-text-content').addClass('d-none'); // Hide the read text
        $('#read-btn').fadeIn(200); // Show the "read" button
    }

    // Function to show the "Read" (Description) section
    function showReadContent() {
        $('#main-gallery-img').addClass('d-none');
        $('#gallery-text-content').removeClass('d-none');
        $('#read-btn').fadeOut(200); // Hide "read" button while reading
    }

    // Sidebar Item Click
    items.on('click', function () {
        selectProject($(this));

        // Mobile: Switch from list view to detail view
        if (window.innerWidth <= 768) {
            $('#mobile-list-container').addClass('d-none-mobile');
            $('#mobile-work-container').removeClass('d-none-mobile');
        }
    });

    // Arrow Button (Next) Logic
    $('#next-image').on('click', function () {
        // 1. If currently in the "Read" section, clicking arrow resets to the 1st image
        if (!$('#gallery-text-content').hasClass('d-none')) {
            showImage(0);
            return;
        }

        // 2. If there are more images left in the array, show the next one
        if (currentImgIndex < projectImages.length - 1) {
            showImage(currentImgIndex + 1);
        }
        // 3. If we are on the last image, show the "Read" section
        else {
            showReadContent();
        }
    });

    // Read Button Click
    $('#read-btn').on('click', function () {
        showReadContent();
    });

    // Mobile "Back to List" Button
    $('#back-to-list').on('click', function () {
        $('#mobile-list-container').removeClass('d-none-mobile');
        $('#mobile-work-container').addClass('d-none-mobile');
    });

    // --- 4. PANELS (About & Contact) ---

    function openAbout() {
        $('#contact-panel').removeClass('open-mobile').fadeOut(200);
        $('#about-panel').addClass('open');
        $('#panel-overlay').fadeIn(400);
    }

    function openContact() {
        $('#about-panel').removeClass('open');
        if (window.innerWidth <= 768) {
            $('#contact-panel').addClass('open-mobile').show();
        } else {
            $('#contact-panel').fadeIn(300);
        }
        $('#panel-overlay').fadeIn(400);
    }

    // Bindings for About/Contact
    $('#open-about, #open-about-from-contact').on('click', function (e) {
        e.preventDefault();
        openAbout();
    });

    $(document).on('click', '.open-contact-btn', function (e) {
        e.preventDefault();
        openContact();
    });

    // Close logic for all panels
    $('#close-about, #close-contact, #panel-overlay').on('click', function () {
        $('#about-panel').removeClass('open');
        $('#contact-panel').removeClass('open-mobile').fadeOut(300);
        $('#panel-overlay').fadeOut(400);
    });

    // About Page "Read More" trigger
    $('#read-more-trigger').on('click', function () {
        $('#dots').hide();
        $('#more-content').fadeIn(600);
        $(this).hide();
    });

    // Handle Window Resize (Fixes contact panel visibility issues)
    $(window).resize(function () {
        if (window.innerWidth > 768) {
            $('#contact-panel').removeClass('open-mobile');
        }
    });
});