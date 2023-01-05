function izl_oc_art_ank(subj_nr, rec_nr)
    string1 = append('eegmmidb/S001/S00',num2str(subj_nr),'R0',num2str(rec_nr), '.edf');
    
    [sig,freq,tm]=rdsamp(string1);
    [ant, ~, ~, ~, ~, cmt]=rdann(string1, 'event');
    
    %narisi vse signale skupaj z mejami
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz osnovnih signalov - vsi naenkrat.','Position', [900 80 1000 900]);
    plot (tm, sig(:, 1:64));
    for i=1:length(ant)
        xline(tm(ant(i)),'--r', cmt(i)); 
    end
    
    sig1 = transpose(sig);
    %narisi po tem ko smo uporabili metodo locevanja in spet prevtorili nazaj, moglo bi biti isto kot
    %prej
    [icasig, A, W] = fastica(sig1);
    preizkus = (A*icasig)';
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz osnovnih signalov po uporabi funkcije fastica in pretvorbi nazaj - vsi naenkrat.','Position', [900 80 1000 900]);
    plot (tm, preizkus(:, 1:64));
    for i=1:length(ant)
        xline(tm(ant(i)),'--r', cmt(i)); 
    end
    
    %narisi vsak signal posebej preden uporabimo metodo
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz osnovnih signalov.','Position', [900 80 1000 900]);
    for i=1:size(sig1,1)-1
        subplot(8,8,i);
        plot (tm, sig1(i,:));
    end
    
    
    %narisi po tem ko smo uporabili metodo vsak signal posebej
    figure('NumberTitle', 'off', 'Name', 'Grafični prikaz signalov v prostoru neodvisnih komponent.','Position', [900 80 1000 900]);
    %the rows of icasig contain the
    % estimated independent components
    %pozicije = zeros(size(icasig,1)-1,4);
    for i=1:size(icasig,1)-1
        subplot(8,8,i);
        plot (tm, icasig(i,:));
        title(num2str(i))
    end
    
    
    %izberi tacudne signale gui
    fig = uifigure('Name', 'Izberi neodvisne komponente, ki jih želiš odstraniti.');
    set(fig,'Position', [100 100 600 600])
    pnl = uipanel(fig,'Position',[50 50 500 500]);
    pnl.Scrollable = 'on';
    lbl = uilabel(fig, 'Text', 'Izberi neodvisne komponente, ki jih želiš odstraniti.', 'Position',[50 550 400 30]);
   
    pozicije = zeros(size(icasig,1)-1,4);
    gumbi = zeros(size(icasig,1)-1,1);
    for i=1:size(icasig,1)-1
        pozicije(i,:) = [50 + 50*mod(i-1,8), 450 - 50*fix((i-1)/8), 50, 30];
        izbira = num2str(i);
        gumbi(i) = uicheckbox(pnl, 'Text',izbira,...
                      'Value', 0,...
                      'Position',pozicije(i,:));
    end
    
    btn = uibutton(pnl,'push',...
                   'Text', 'Izberi',...
                   'Position',[50, 50, 100, 25],...
                   'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn,fig,gumbi,icasig,A,tm));

     % ko kliknes na gumb se tacudni signali izbrisejo in spet pretvorimo
    % signale nazaj
    function plotButtonPushed(btn,fig,gumbi,icasig,A,tm)
          nova = icasig;
          novia = A;
          rezultati = cell2mat(get(gumbi, 'Value'));
          za_zbrisat = zeros(sum(rezultati),1);
          j=1;
          for k=1:size(rezultati)
              if rezultati(k)==1
                  za_zbrisat(j) = k;
                  j =j+1;
              end
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
    
          close(fig)
    end
end

