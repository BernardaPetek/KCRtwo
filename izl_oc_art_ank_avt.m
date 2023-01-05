function izl_oc_art_ank_avt(subj_nr, rec_nr, procent_zunanjih,koeficient_deviacije)
    string1 = append('eegmmidb/S001/S00',num2str(subj_nr),'R0',num2str(rec_nr), '.edf');    
    [sig,freq,tm]=rdsamp(string1);
    [ant, ~, ~, ~, ~, cmt]=rdann(string1, 'event');
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz osnovnih signalov - vsi naenkrat.','Position', [900 80 1000 900])
    plot (tm, sig(:, 1:64));
    for i=1:length(ant)
        xline(tm(ant(i)),'--r', cmt(i)); 
    end
    
    sig1 = transpose(sig);
    %narisi vsak signal posebej
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz osnovnih signalov.','Position', [900 80 1000 900]);
    for i=1:size(sig1,1)-1
        subplot(8,8,i);
        plot (tm, sig1(i,:));
    end
    [icasig, A, W] = fastica(sig1);
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz signalov v prostoru neodvisnih komponent.','Position', [900 80 1000 900]);
    %the rows of icasig contain the
    % estimated independent components
    for i=1:size(icasig,1)-1
        subplot(8,8,i);
        plot (tm, icasig(i,:));
        title(num2str(i))
    end
    
 
    vsi = size(icasig,2);
    nr_primerjava = (procent_zunanjih/100)*vsi;
    za_zbrisat = [];
    izbrisane_komponente =[];
    %odrezi tiste ki so prevec cudni
    for i=1:size(icasig,1)-1
        standardna_dev = std(icasig(i,:),1);
        povprecje = mean(icasig(i,:));
        meja1 = koeficient_deviacije*standardna_dev + povprecje;
        meja2 = (-koeficient_deviacije)*standardna_dev + povprecje;
        prva_meja = icasig(i,:) < meja1;
        druga_meja = icasig(i,:) > meja2;
        pomozna = prva_meja+druga_meja;
        st_dobrih = sum(pomozna==2);
        st_slabih = vsi - st_dobrih;
        if st_slabih > nr_primerjava
            za_zbrisat = [za_zbrisat; i];
            izbrisane_komponente = [izbrisane_komponente; icasig(i,:)];
        end
    end
    
    
    nova = icasig;
    novia = A;

    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz korigiranih signalov, ki smo jih izbrisali.', 'Position', [900 80 1000 900]);
     for k=1:size(izbrisane_komponente,1)
      subplot(8,8,k);
      plot (tm, izbrisane_komponente(k,:));
     end

    for k=1:size(za_zbrisat)
      nova(za_zbrisat(k)-k+1,:) = [];
      novia(:,za_zbrisat(k)-k+1) = [];
    end
    
    rez = novia*nova;
    
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz korigiranih signalov.', 'Position', [900 80 1000 900]);
    for k=1:size(rez,1)-1
      subplot(8,8,k);
      plot (tm, rez(k,:));
    end
    

end