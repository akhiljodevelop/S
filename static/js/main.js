$(document).ready(function () {
    // Supabase Configuration
    const supabaseUrl = 'https://wdquptbkicyzzvjyzdyn.supabase.co';
    const supabaseKey = 'sb_publishable_m46Uh53QJTxB0KNm0b9mlw_8auRxMtp';
    const _supabase = supabase.createClient(supabaseUrl, supabaseKey);

    // Global Variables for Gallery State
    let projectImages = []; // Array of images for the active project
    let currentImgIndex = 0; // Current image being viewed (0, 1, 2...)
    let allProjects = [];

    // --- 1. INITIALIZATION & LOADER ---
    async function initApp() {
        await fetchProfile();
        await fetchPress();

        setTimeout(function () {
            $('#loader').fadeOut(800, function () {
                $('#main-content').removeClass('d-none').addClass('fade-in');
            });
        }, 3000);
    }

    initApp();

    // --- 2. DATA FETCHING ---
    function formatParagraphs(text) {
        if (!text) return '';
        return text.split(/\r?\n/).filter(p => p.trim() !== '').map(p => `<p>${p}</p>`).join('');
    }

    async function fetchProfile() {
        const { data, error } = await _supabase
            .from('profile')
            .select('*')
            .maybeSingle();

        if (data) {
            $('#about-img').attr('src', data.about_image_url);
            $('#about-intro').html(formatParagraphs(data.about_text_intro));
            $('#about-more-span').html(formatParagraphs(data.about_text_more));
            $('#contact-email').attr('href', 'mailto:' + data.email).text(data.email);
            $('#contact-insta').attr('href', data.instagram_url).text(data.instagram_handle);
        }
    }

    async function fetchPress() {
        const { data, error } = await _supabase
            .from('press_items')
            .select('*')
            .order('sort_order', { ascending: true });

        if (data) {
            const pressHtml = data.map(item => `
                <a href="${item.url}" class="press-sec" target="_blank" rel="noopener noreferrer">
                    <div class="press-item">
                        <p class="press-source">${item.source}</p>
                        <p class="press-content">${item.content}</p>
                    </div>
                </a>
            `).join('');
            $('#press-list').html(pressHtml);
        }
    }

    async function fetchProjects(category) {
        const { data, error } = await _supabase
            .from('projects')
            .select('*')
            .eq('category', category)
            .order('sort_order', { ascending: true });

        if (data) {
            allProjects = data;
            renderGalleryList();

            // Auto-select first project on desktop
            if (window.innerWidth > 768 && allProjects.length > 0) {
                selectProject(0);
            }
        }
    }

    // --- 3. RENDERING & GALLERY LOGIC ---
    function renderGalleryList() {
        const listHtml = allProjects.map((project, index) => `
            <li class="gallery-item" data-index="${index}">
                <span class="g-num">${(index + 1).toString().padStart(2, '0')}</span>
                <span class="g-title">${project.title}</span>
            </li>
        `).join('');
        $('#gallery-items-list').html(listHtml);

        $('.gallery-item').on('click', function () {
            const idx = $(this).data('index');
            selectProject(idx);

            // Mobile: Switch from list view to detail view
            if (window.innerWidth <= 768) {
                $('#mobile-list-container').addClass('d-none-mobile');
                $('#mobile-work-container').removeClass('d-none-mobile');
            }
        });
    }

    function selectProject(index) {
        const project = allProjects[index];
        if (!project) return;

        $('.gallery-item').removeClass('active');
        $(`.gallery-item[data-index="${index}"]`).addClass('active');

        projectImages = project.images || [];
        currentImgIndex = 0;

        // Update Text Content
        $('#text-title, #display-title-mobile').text(project.title);
        $('#display-num').text((index + 1).toString().padStart(2, '0'));
        $('#display-desc').html(formatParagraphs(project.description));

        // Update Metadata
        $('.metadata').html(formatParagraphs(project.metadata_info));

        // Reset view to show the first image
        showImage(0);
    }

    function showImage(index) {
        currentImgIndex = index;
        if (projectImages.length > 0) {
            $('#main-gallery-img').attr('src', projectImages[currentImgIndex]).removeClass('d-none');
        } else {
            $('#main-gallery-img').addClass('d-none');
        }
        $('#gallery-text-content').addClass('d-none'); // Hide the read text
        $('#read-btn').fadeIn(200); // Show the "read" button
    }

    function showReadContent() {
        $('#main-gallery-img').addClass('d-none');
        $('#gallery-text-content').removeClass('d-none');
        $('#read-btn').fadeOut(200); // Hide "read" button while reading
    }

    // --- 4. NAVIGATION ---
    $('.category-trigger').on('click', function (e) {
        e.preventDefault();
        const category = $(this).data('category');

        $('.category-trigger').removeClass('fw-bold');
        $(this).addClass('fw-bold');

        $('#home-view').fadeOut(400, function () {
            $('#gallery-view').hide().removeClass('d-none').fadeIn(600);
            fetchProjects(category);
        });
    });

    $('#go-home').on('click', function () {
        $('#gallery-view').fadeOut(400, function () {
            $('#home-view').fadeIn(600);
        });
        $('.category-trigger').removeClass('fw-bold');
    });

    // Arrow Button (Next) Logic
    $('#next-image').on('click', function () {
        if (!$('#gallery-text-content').hasClass('d-none')) {
            showImage(0);
            return;
        }

        if (currentImgIndex < projectImages.length - 1) {
            showImage(currentImgIndex + 1);
        } else {
            showReadContent();
        }
    });

    $('#read-btn').on('click', function () {
        showReadContent();
    });

    $('#back-to-list').on('click', function () {
        $('#mobile-list-container').removeClass('d-none-mobile');
        $('#mobile-work-container').addClass('d-none-mobile');
    });

    // --- 5. PANELS (About & Contact) ---
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

    $('#open-about, #open-about-from-contact').on('click', function (e) {
        e.preventDefault();
        openAbout();
    });

    $(document).on('click', '.open-contact-btn', function (e) {
        e.preventDefault();
        openContact();
    });

    $('#close-about, #close-contact, #panel-overlay').on('click', function () {
        $('#about-panel').removeClass('open');
        $('#contact-panel').removeClass('open-mobile').fadeOut(300);
        $('#panel-overlay').fadeOut(400);
    });

    $('#read-more-trigger').on('click', function () {
        $('#about-more-span').fadeIn(600);
        $(this).hide();
    });

    $(window).resize(function () {
        if (window.innerWidth > 768) {
            $('#contact-panel').removeClass('open-mobile');
        }
    });
});
