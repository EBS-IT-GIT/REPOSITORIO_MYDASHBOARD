CREATE OR REPLACE PROCEDURE APPS."XXHR_SYNC"
AS
--
  CURSOR c_person IS
  SELECT
    xntfu.nro_leg,xntfu.fec_estado,ppf2.person_id  ,
    Nvl (fu.user_name, 'X') user_name ,
    xntfu.fnd_user_status
    , ppf2.effective_end_date
    , fu.end_date
  FROM bolinf.xx_nexus_to_fnd_user xntfu,
  (
    SELECT
      REPLACE (REPLACE (ppf.employee_number, 'AR', '')  , 'UR','') nro_leg
      , ppf.person_id
      , ppf.effective_end_date
    FROM
      apps.per_people_f ppf, hr.per_person_types ppt
    WHERE 1=1 
       AND (SUBSTR (ppf.employee_number, 1, 2) = 'AR' OR SUBSTR (ppf.employee_number, 1, 2) = 'UR')
      AND ppf.current_employee_flag = 'Y'
      AND ppf.person_type_id = ppt.person_type_id
      AND ppt.system_person_type = 'EMP'
  ) ppf2
  , applsys.fnd_user fu
  WHERE
    TO_CHAR (xntfu.nro_leg) = ppf2.nro_leg
    AND xntfu.estado = 'INAC'
    AND xntfu.fec_estado <= Trunc (SYSDATE)
    --AND Nvl(xntfu.fnd_user_status,'E') = 'E'
    AND xntfu.fnd_user_status IS NULL
    AND ppf2.person_id = fu.employee_id (+)
  ;
  --
  CURSOR c_fnd_user_data (p_person_id IN NUMBER) IS
  SELECT
    fu.user_id
    , furga.responsibility_id
    , furga.responsibility_application_id
    , furga.security_group_id
    , furga.start_date
  FROM applsys.fnd_user fu, apps.fnd_user_resp_groups_all furga
  WHERE fu.employee_id = p_person_id
  AND fu.user_id = furga.user_id
  ;
  --
  r_person c_person%ROWTYPE;
  --
  r_fnd_user_data c_fnd_user_data%ROWTYPE;
  --
  l_error_msg               VARCHAR2(600);
--
BEGIN
--
  OPEN c_person;
  --
  LOOP
  --
    FETCH  c_person INTO r_person;
    EXIT WHEN c_person%NOTFOUND;
    dbms_output.put_line ('person_id = '||r_person.person_id);
    --
    l_error_msg := NULL;
    --
    IF r_person.fec_estado < r_person.effective_end_date THEN
    --
      IF r_person.fec_estado <= Trunc (SYSDATE) THEN
        /*
        UPDATE per_people_f ppf
        SET ppf.effective_end_date = Trunc (SYSDATE)--r_person.fec_estado
        WHERE ppf.person_id = r_person.person_id
        ;
        */
        --
        declare
        --
          --Common Variables
          l_terminate_emp_flag          varchar2(1) := 'N';
          --
          l_person_id                   number := r_person.person_id;
          l_le_terminate_emp_exception  exception;
          --
          --- DECLARE variables for HR_EX_EMPLOYEE_WORKER_API.actual_termination_emp
          --- IN variables
          l_effective_date              date;
          --l_termination_reason          per_periods_of_service.leaving_reason%type := 'MUTUAL_AGREEMENT';
          l_person_type_id              per_person_types.person_type_id%type := 6;
          l_period_of_service_id        per_periods_of_service.period_of_service_id%type;
          l_actual_termination_date     per_periods_of_service.actual_termination_date%type :=TRUNC(sysdate);
          l_last_standard_process_date  per_periods_of_service.last_standard_process_date%type := TRUNC(sysdate+10);
          l_object_version_number       per_periods_of_service.object_version_number%type;
          l_start_date                  per_periods_of_service.date_start%type;
          l_notif_term_date             date;
          --
          --- OUT variables
          l_supervisor_warning         boolean := false;
          l_event_warning              boolean := false;
          l_interview_warning          boolean := false;
          l_review_warning             boolean := false;
          l_recruiter_warning          boolean := false;
          l_asg_future_changes_warning boolean := false;
          l_entries_changed_warning    varchar2(300);
          l_pay_proposal_warning       boolean := false;
          l_dod_warning                boolean := false;
          l_alu_change_warning         varchar2(300);
          --
          --- DECLARE variables for HR_EX_EMPLOYEE_WORKER_API.final_process_emp
          --- IN variables
          l_final_process_date             per_periods_of_service.final_process_date%type;
          --
          --- OUT variables
          l_org_now_no_manager_warning     boolean := false;
          l_f_asg_future_changes_warning   boolean := false;
          l_f_entries_changed_warning      varchar2(300);
        --
        begin
        --
          begin
          --
            select
              pos.period_of_service_id
              , pos.object_version_number
              , date_start
            into l_period_of_service_id, l_object_version_number, l_start_date
            from hr.per_periods_of_service pos
            where pos.person_id = l_person_id;
          exception
          when others then
          --
            l_error_msg  := 'Error while selecting employee details : '||substr(sqlerrm,1,150);
            raise l_le_terminate_emp_exception;
          --
          end;
          --
          savepoint terminate_employee_s1;
          --
          begin
          --
            /*
            * This API terminates an employee.
            * This API converts a person of type Employee >to a person of type
            * Ex-Employee. The person's period of service and any employee assignments are ended.
            */
            apps.hr_ex_employee_api.actual_termination_emp
            (p_validate                         => false--l_validate
            ,p_effective_date                   => TRUNC(SYSDATE)
            ,p_period_of_service_id             => l_period_of_service_id
            ,p_object_version_number            => l_object_version_number
            ,p_actual_termination_date          => l_actual_termination_date
            ,p_last_standard_process_date       => l_last_standard_process_date
            --,p_person_type_id                   => l_person_type_id
            --  ,p_leaving_reason                   => l_termination_reason
            --Out
            ,p_supervisor_warning               => l_supervisor_warning
            ,p_event_warning                    => l_event_warning
            ,p_interview_warning                => l_interview_warning
            ,p_review_warning                   => l_review_warning
            ,p_recruiter_warning                => l_recruiter_warning
            ,p_asg_future_changes_warning       => l_asg_future_changes_warning
            ,p_entries_changed_warning          => l_entries_changed_warning
            ,p_pay_proposal_warning             => l_pay_proposal_warning
            ,p_dod_warning                      => l_dod_warning
            -- ,p_alu_change_warning               => l_alu_change_warning
            );
            --
            if l_object_version_number is null then
            --
              l_terminate_emp_flag := 'N';
              l_error_msg      := 'Warning validating API: hr_ex_employee_api.actual_termination_emp';
              raise l_le_terminate_emp_exception;
            --
            end if;
            --
            l_terminate_emp_flag := 'Y';
          --
          exception
          when others then
          --
            l_error_msg  := 'Error validating API: hr_ex_employee_api.actual_termination_emp : '||substr(sqlerrm,1,150);
            raise l_le_terminate_emp_exception;
          --
          end; -- hr_ex_employee_api.actual_termination_emp
          --
          if l_terminate_emp_flag = 'Y' then
          --
            begin
            --
              if l_start_date > TRUNC(sysdate) then
                l_notif_term_date := l_start_date + 1;
              else
                l_notif_term_date := TRUNC(SYSDATE);
              end if;
              --
              /*
              * This API updates employee termination information.
              * The ex-employee must exist in the relevant business group
              */
              apps.hr_ex_employee_api.update_term_details_emp
              (p_validate                      => false--l_validate
              ,p_effective_date                => TRUNC(SYSDATE)
              ,p_period_of_service_id          => l_period_of_service_id
              ,p_notified_termination_date     => l_notif_term_date
              ,p_projected_termination_date    => l_notif_term_date
              --In/Out
              ,p_object_version_number         => l_object_version_number
              );
            --
            exception
            when others then
            --
              l_error_msg  := 'Error validating API: hr_ex_employee_api.update_term_details_emp : '||substr(sqlerrm,1,150);
              l_terminate_emp_flag := 'N';
              raise l_le_terminate_emp_exception;
            --
            end; --hr_ex_employee_api.update_term_details_emp
            --
            begin
            --
              /*
              * This API set the final process date for a terminated employee.
              * This API covers the second step in terminating a period of service and all
              * current assignments for an employee. It updates the period of service
              * details and date-effectively deletes all employee assignments as of the final process date.
              */
              --
              l_final_process_date := Trunc (SYSDATE +1);
              /* apps.hr_ex_employee_api.final_process_emp
              (p_validate                      => false--l_validate
              ,p_period_of_service_id          => l_period_of_service_id
              --Out
              ,p_object_version_number         => l_object_version_number
              ,p_final_process_date            => l_final_process_date
              ,p_org_now_no_manager_warning    => l_org_now_no_manager_warning
              ,p_asg_future_changes_warning    => l_f_asg_future_changes_warning
              ,p_entries_changed_warning       => l_f_entries_changed_warning
              );
              */
            --
            exception
            when others then
            --
              l_error_msg := 'Error validating API: hr_ex_employee_api.final_process_emp : '||substr(sqlerrm,1,150);
              raise l_le_terminate_emp_exception;
            --
            end; --hr_ex_employee_api.final_process_emp
          --
          end if;
          --
          commit;
        --
        exception
        when l_le_terminate_emp_exception then
        --
          dbms_output.put_line(l_error_msg);
          rollback to terminate_employee_s1;
        --
        when others then
        --
          dbms_output.put_line('Terminate Employee. Error OTHERS while validating: '||sqlerrm);
          rollback to terminate_employee_s1;
        --
        end;
      --
      END IF;
    --
    END IF ;  -- IF r_person.fec_estado < r_person.effective_end_date THEN
    --
    IF r_person.user_name != 'X' AND r_person.fec_estado < Nvl (r_person.end_date, SYSDATE +1)  THEN
    --
      BEGIN
      --
        apps.fnd_user_pkg.updateuser (x_user_name                    =>   r_person.user_name,
        x_owner                        => NULL,
        x_end_date                     => Trunc (SYSDATE), --r_person.fec_estado,
        x_user_guid                    => NULL

        );
        /*
        OPEN  c_fnd_user_data (r_person.person_id);
        LOOP
        --
          FETCH c_fnd_user_data INTO r_fnd_user_data;
          EXIT WHEN c_fnd_user_data%NOTFOUND;
          dbms_output.put_line ('r_fnd_user_data.responsibility_id = '||r_fnd_user_data.responsibility_id);
          apps.fnd_user_resp_groups_api.update_assignment(
          user_id                        => r_fnd_user_data.user_id,
          responsibility_id              => r_fnd_user_data.responsibility_id,
          responsibility_application_id  => r_fnd_user_data.responsibility_application_id,
          security_group_id              => r_fnd_user_data.security_group_id,
          start_date                     => r_fnd_user_data.start_date,
          end_date                       => Trunc (SYSDATE), -- r_person.fec_estado,
          description                    => 'Baja Nexus');
        --
        END LOOP;
        CLOSE c_fnd_user_data;
        */
      --
      EXCEPTION
      WHEN OTHERS THEN
      --
        l_error_msg := SubStr (SQLERRM,1, 200);
      --
      END;
    --
    END IF;  -- IF r_person.user_name != 'X' AND r_person.fec_estado < Nvl (r_person.end_date, SYSDATE +1)  THEN
    --
    IF l_error_msg IS NOT NULL THEN
    --
      UPDATE bolinf.xx_nexus_to_fnd_user
      SET fnd_user_errm  = l_error_msg
      , fnd_user_status = 'E'
      WHERE
      nro_leg = r_person.nro_leg;
    --
    ELSE
    --
      UPDATE bolinf.xx_nexus_to_fnd_user
      SET fnd_user_status = 'U'
      , fnd_user_date = TRUNC (SYSDATE)
      WHERE
      nro_leg = r_person.nro_leg;
    --
    END IF;
  --
  END LOOP;
  --
  CLOSE c_person;
--
-- --Cuando se vuelta a dar alta un usuario que ya existia, hay que borrar el FND_USER_STATUS, para la prox baja la realice OK
BEGIN
update bolinf.xx_nexus_to_fnd_user xntfu
set fnd_user_status = NULL, estado = 'ACTI'
where nro_leg in (
select substr(per.employee_number, 3,10)  from fnd_user fu, per_all_people_F per
where trunc(fu.last_update_Date) = trunc(sysdate)
and per.person_id = fu.employee_id
and estado = 'INAC'
and sysdate between per.effective_start_date and per.effective_end_date);

EXCEPTION
 when others then
   null; -- que no interfiera con el proceso ppal
END;


END;
/
